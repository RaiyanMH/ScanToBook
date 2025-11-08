# ScanToBook

A professional Flutter application for scanning book pages and creating digital book collections. ScanToBook combines the functionality of a document scanner with a manga-style reader, allowing users to capture, organize, and read their scanned pages with a beautiful, modern interface.

## Features

### 📚 Book Management
- **Create Books**: Scan or upload pages to create digital book collections
- **Multi-select**: Upload multiple images at once
- **Continuous Capture**: Take photos in sequence for quick page scanning
- **Grid View**: Browse your books in a beautiful card-based grid layout
- **Search**: Quickly find books by title
- **Custom Covers**: Set custom cover images for each book

### 📖 Reading Experience
- **Professional Reader**: Manga-style reading interface with auto-hiding controls
- **Multiple Reading Modes**:
  - Horizontal scrolling (tap left/right to navigate)
  - Vertical scrolling (scroll through pages)
  - Two-page view on larger screens (tablets/desktops)
- **Reading Direction**: Support for left-to-right and right-to-left reading
- **Page Order**: Option to reverse page order (first to last or last to first)
- **Keyboard Navigation**: Arrow keys for desktop navigation
- **Progress Tracking**: Automatically saves reading progress per book
- **Zoom & Pan**: Pinch to zoom and pan through pages using PhotoView

### 🎨 Customization
- **Multiple Themes**: 
  - OLED Black (true black for OLED displays)
  - Blue Dark (#192D73 background)
  - Sepia (warm, paper-like appearance)
  - Green Dark
  - Purple Dark
  - System (follows device theme)
- **Text Size**: Adjustable text size throughout the app
- **Per-Book Settings**: Each book remembers its own reading preferences

### ✏️ Book Editing
- **Rearrange Pages**: Drag and drop to reorder pages (when rearrange mode is enabled)
- **Add/Remove Pages**: Easily add new pages or delete unwanted ones
- **Rename Books**: Update book titles anytime
- **Set Cover**: Choose any page as the book cover or upload a custom image
- **Export**: Export entire books as PDF files

### 📱 Platform Support
- **Web**: Full functionality on Chrome and other browsers
- **Mobile**: Optimized for phones and tablets
- **Desktop**: Responsive design adapts to screen size

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- For mobile development: Android Studio / Xcode
- For web development: Chrome browser

### Installation

1. Clone the repository:
```bash
git clone https://github.com/RaiyanMH/ScanToBook.git
cd scantobook
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For Android
flutter run

# For iOS
flutter run
```

## Usage

### Creating a Book
1. Tap the **+** button on the home screen
2. Enter a book title
3. Choose to:
   - **Scan Page**: Take a photo with your camera
   - **Pick from Gallery**: Select from existing photos
   - **Multi-select**: Choose multiple images at once
   - **Continuous**: Take multiple photos in sequence
4. Review and remove pages as needed
5. Tap **Save Book** when done

### Reading a Book
1. Tap on any book from the home screen
2. View book details, progress, and page count
3. Tap **Read** or **Continue** to open the reader
4. Navigate using:
   - **Tap left/right** edges of screen (horizontal mode)
   - **Scroll** up/down (vertical mode)
   - **Arrow keys** on desktop
   - **Bottom bar controls**: First, Previous, Slider, Next, Last
5. Tap top or bottom of screen to show/hide controls

### Managing Books
- **3-dot menu** on each book card:
  - Rename
  - Set Cover (Upload)
  - Delete
  - Export as PDF

- **3-dot menu** in book details:
  - Rename
  - Set Cover
  - Add Page
  - Rearrange Pages (enables drag-to-reorder)
  - Delete Pages
  - Delete
  - Export as PDF

### Reader Settings
Access via the settings icon in the reader:
- **Reading Direction**: Left-to-right or Right-to-left
- **Scroll Direction**: Horizontal or Vertical
- **Page Order**: Normal or Reversed

## Technical Details

### Architecture
- **State Management**: Provider pattern
- **Image Handling**: Platform-specific (bytes for web, files for mobile)
- **Storage**: In-memory (local data persistence can be added)

### Dependencies
- `provider`: State management
- `image_picker`: Camera and gallery access
- `photo_view`: Image viewing with zoom/pan
- `pdf` & `printing`: PDF export functionality
- `reorderable_grid_view`: Page reordering
- `uuid`: Unique ID generation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available for personal and commercial use.

## Acknowledgments

- Inspired by manga reading apps like Kotatsu
- UI/UX patterns inspired by modern document scanner applications
