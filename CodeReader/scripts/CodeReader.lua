--[[----------------------------------------------------------------------------

  Application Name:
  CodeReader
                                                                                             
  Summary:
  Reading QR Codes from local resource files
  
  Description:
  Script loads periodically all images inside the 'resources' folder.
  If there are codes successfully found in one of the images, the content
  and coordinates of the codes are printed
  
  How to run:
  The sample can be run using the SIM4000 emulator. The result is printed to the
  console. The ImageView shows the images and marks the found codes.
  Additional Images with QR codes can be placed in the resource folder.
  
  More Information:
  See also Sample BarcodeReader for reading UPC/EAN codes
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

local IMAGE_PATH = 'resources/'

-- Creating an image provider
local handle = Image.Provider.Directory.create()
Image.Provider.Directory.setPath(handle, IMAGE_PATH)
Image.Provider.Directory.setCycleTime(handle, 3000)

-- Creating a CodeReader instance
local deco = Image.CodeReader.create()
-- Creating QR decoder instance
local decoQR = Image.CodeReader.QR.create()
-- Setting decoder to read also inverted code
Image.CodeReader.QR.setCodeBackground(decoQR, 'Both')
-- Appending QR decoder to CodeReader
Image.CodeReader.setDecoder(deco, 'Append', decoQR)

-- Creating a viewer instance
local viewer = View.create()
viewer:setID('viewer2D')

local sDecoration = View.ShapeDecoration.create()
View.ShapeDecoration.setLineColor(sDecoration, 0, 255, 0) -- green

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--Declaration of the 'main' function as an entry point for the event loop
--@main()
local function main()
  -- Starting provider after Engine.OnStarted event was received
  Image.Provider.Directory.start(handle)
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

-- Definition of the callback function which is registered at the driver
-- img contains the image itself
-- supplements contains supplementary information about the image
local function handleNewImage(img, supplements)
  print('=====================================')
  -- Retrieving the file name from the supplementary data
  local origin = SensorData.getOrigin(supplements)
  print("Image: '" .. origin .. "'")
  -- Presenting the actual image in the image viewer
  View.view(viewer, img)

  -- Calling the decoder which returns all found codes
  local codes = Image.CodeReader.decode(deco, img)
  print('Codes found: ' .. #codes)

  -- Iterating through the decoding results
  for i = 1, #codes do
    -- Retrieving the content from the codes
    local content = Image.CodeReader.Result.getContent(codes[i])
    -- Retrieving the coordinates from the codes
    local region = Image.CodeReader.Result.getRegion(codes[i])
    local cog = Shape.getCenterOfGravity(region)
    local cx,
      cy = Point.getXY(cog)
    local str = string.format('%s - CX: %s, CY: %s, Content: "%s"', i, cx, cy, content)
    print(str)
    -- Viewing the region
    View.view(viewer, region, sDecoration)
  end
end
Image.Provider.Directory.register(handle, 'OnNewImage', handleNewImage)

--End of Function and Event Scope------------------------------------------------
