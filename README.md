# RetroDiffusion iOS App

A SwiftUI iOS app for generating and pixelating images using the RetroDiffusion API.

## Features

- **Pixelate Tab**: Select images from your photo library and convert them to pixel art using the `rd_pro__pixelate` style
  - Real-time cost preview before pixelation
  - Save pixelated images to your photo library
- **Generate Tab**: Generate pixel art images from text prompts using various RetroDiffusion model styles
  - Debounced cost preview (updates after you stop typing)
  - Model selection with 30+ styles (RD_PRO, RD_FAST, RD_PLUS)
  - Customizable image dimensions
  - Save generated images to your photo library

## Setup

### Prerequisites

- iOS 26.1 or later
- Xcode 26.1 or later
- RetroDiffusion API key

### API Key Configuration

1. Create a `Config.plist` file in the `RetroDiffusionApp` directory if it doesn't exist
2. Add the following structure to the plist file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>YOUR_API_KEY_HERE</string>
</dict>
</plist>
```

3. Replace `YOUR_API_KEY_HERE` with your actual RetroDiffusion API key
4. Get your API key from [RetroDiffusion Dev Tools](https://www.retrodiffusion.ai/app/devtools)

**Important**: The `Config.plist` file is already added to `.gitignore` to prevent committing your API key to version control.

## Architecture

- **SwiftUI**: Fully SwiftUI-based UI with component-based architecture
- **@Observable**: Uses the `@Observable` macro for environment objects (Networking service)
- **Local State**: View state is kept local in views, not in environment objects
- **Environment Injection**: Services are initialized in the app entry point and injected via `@Environment`
- **Component-Based**: Views are broken down into reusable, focused components
- **Separation of Concerns**: Clear separation between networking, models, utilities, and UI components

## API Documentation

For detailed API documentation, visit:
- [RetroDiffusion API Examples](https://github.com/Retro-Diffusion/api-examples/blob/main/README.md)

## Project Structure

```
RetroDiffusionApp/
├── RetroDiffusionAppApp.swift    # App entry point with service initialization
├── Config.plist                  # API key configuration (gitignored)
├── Assets.xcassets/              # App assets
│
├── components/                   # UI Components
│   ├── MainTabView.swift         # Main tab view with two tabs
│   ├── PixelateView.swift        # Photo picker and pixelation functionality
│   ├── GenerateView.swift         # Model selection and image generation
│   ├── CostPreviewView.swift     # Cost preview component
│   ├── ImageDisplayView.swift    # Reusable image display
│   ├── SaveImageButton.swift     # Save to photos button
│   ├── EmptyStateView.swift      # Empty state component
│   ├── PrimaryButton.swift       # Primary action button
│   ├── ModelPickerView.swift     # Model selection picker
│   ├── PromptInputView.swift     # Prompt text input
│   ├── SizeControlsView.swift    # Width/height controls
│   └── PhotoPickerView.swift     # Photo picker component
│
├── models/                       # Data Models
│   └── Models.swift              # API request/response models, RetroDiffusionModel enum
│
├── networking/                    # Networking Layer
│   └── Networking.swift          # @Observable service for API communication
│
└── utils/                        # Utilities
    ├── ConfigLoader.swift         # Load API key from Config.plist
    ├── ImageUtils.swift           # Image resizing and base64 conversion
    └── ImageSaver.swift           # Save images to photo library
```

## Usage

### Pixelate Images

1. Open the "Pixelate" tab
2. Tap "Choose Photo" to select an image from your photo library
3. View the cost preview (automatically calculated)
4. Tap "Pixelate Image" to convert it to pixel art
5. View the original and pixelated images side-by-side
6. Tap "Save to Photos" to save the pixelated image to your photo library

### Generate Images

1. Open the "Generate" tab
2. Select a model style from the picker (30+ styles available)
3. Enter a text prompt describing the image you want to generate
4. Optionally adjust the width and height (default: 256x256)
5. View the cost preview (updates automatically after you stop typing)
6. Tap "Generate Image" to create pixel art
7. View the generated image
8. Tap "Save to Photos" to save the generated image to your photo library

## Requirements

- iOS 26.1+
- Swift 5.0+
- RetroDiffusion API account with credits
