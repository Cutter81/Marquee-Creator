# Marquee Creator v1.3

**Marquee Creator** is a Windows utility by Cutter81 for generating marquee images for RetroBat collections, including numbered episode/video collections and comic issue collections.

It reads the text it needs from your media **filenames**. You choose the collection's system folder, select a logo image, choose an artwork-text mode, and the utility creates the marquee images automatically.

## Features

- Creates marquee artwork from text extracted from filenames.
- Supports episode-number, episode-name, episode-number-plus-name, and comic-issue modes.
- Sorts episode files by season and episode before generating numbered marquees; episode numbering continues across seasons.
- Lets you choose the logo image used in the marquee.
- Writes generated images to the system folder's `media\marquee` directory.
- Creates an activity log and lists files that do not match the selected naming format.
- Skips existing output images rather than overwriting them.
- Uses the included RazorBlade icon for the application.

## Requirements

- Windows with Windows PowerShell 5.1 or later.
- ImageMagick installed, with `magick.exe` available on your `PATH`.
- A logo image to use as the marquee artwork (for example, `logo.png`).

## Getting Started

1. Extract the Marquee Creator files to a folder.
2. Make sure ImageMagick is installed and `magick.exe` can be found through `PATH`.
3. Launch Marquee Creator.
4. Under **System folder**, choose the RetroBat system folder containing the source media files.
5. Under **Logo image**, select the logo image to use in the generated marquees.
6. Choose the **Artwork text** mode that matches your filenames.
7. Optionally enable **Include episode name with episode number** when using Episode Number mode.
8. Click **Create Marquees**.
9. Review the activity log for successful files, skipped files, or errors.

Generated images are saved automatically in:

`<system folder>\media\marquee`

The output log is written to:

`<system folder>\000-Marquee-Creator-Output.txt`

## Filename Formats and Modes

Marquee Creator extracts the relevant text from the filename (without its file extension). The files must match the naming convention for the selected mode; files that do not match are skipped and reported in the activity log.

### 1. Episode Number

Expected filename format:

`Series Name - S01E01.ext`

For example:

`Example Series - S01E01.mp4`

The utility sorts matching files by season and episode, then generates sequential labels such as `Episode 1`, `Episode 2`, and so on. Numbering continues across seasons rather than restarting at each season.

### 2. Episode Name

Expected filename format:

`Series Name - S01E01 - Episode Name.ext`

For example:

`Example Series - S01E01 - The First Episode.mp4`

The generated marquee text is the episode name extracted from the filename.

### 3. Episode Number + Name (Optional)

Select **Episode Number** and enable **Include episode name with episode number**.

Expected filename format:

`Series Name - S01E01 - Episode Name.ext`

For example:

`Example Series - S01E01 - The First Episode.mp4`

The generated marquee text combines the sequential episode number with the episode name, such as `Episode 1 - The First Episode`. Numbering continues across seasons.

### 4. Comic Issue

Expected filename format:

`Series Name - Issue 001.ext`

For example:

`Example Comic - Issue 001.cbz`

The generated marquee text uses the issue number from the filename, formatted as `Issue 1`, `Issue 2`, and so on.

## Output Files

For each matching source file, the utility creates a PNG in the `media\marquee` output folder. The output filename is based on the original source filename, with `-marquee.png` appended to the filename stem.

Example:

- Source: `Example Series - S01E01.mp4`
- Output: `Example Series - S01E01-marquee.png`

If the expected output file already exists, Marquee Creator skips that file to avoid overwriting it.

## Activity Log and Troubleshooting

The activity log appears in the application's window. When a run begins, a full log is also written to `000-Marquee-Creator-Output.txt` in the selected system folder.

The log reports matched files, skipped files, successful output generation, and errors.

- **No files matched:** Check that the filenames follow the exact format required by the selected mode.
- **Logo image required:** Select a valid image file in the **Logo image** field.
- **System folder required:** Select a valid system folder containing the source files.
- **ImageMagick not found:** Install ImageMagick or correct your `PATH` so `magick.exe` can be found, then run the utility again.
- **Existing output skipped:** The corresponding marquee already exists. The utility intentionally does not overwrite it.

## Included Files

- `MarqueeCreator-v1.3.ps1` — the PowerShell graphical application.
- `MarqueeCreatorLauncher-v1.3.cs` — the C# launcher source.
- `Build-MarqueeCreator-v1.3-EXE-with-RazorBlade.bat` — the batch file for building the executable.
- `MarqueeCreator-RazorBlade.ico` — the application icon.

## Notes

- Marquee Creator generates artwork using the selected logo image and text extracted from source filenames; it does not read episode titles or issue numbers from the image contents.
- Source files that do not match the selected naming format are skipped and listed in the log.
- Existing marquee PNGs are not overwritten.

## Credits

**Marquee Creator v1.3 by Cutter81**
