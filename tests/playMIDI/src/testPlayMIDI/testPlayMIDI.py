import pygame
import time

import pathlib

# Define the directory containing MIDI files
MIDI_DIR = pathlib.Path(__file__).parent.parent.parent.parent.parent / "midi-samples"

class Player:
    def __init__(self, file_path) -> None:
        """
        Initialize a Player object with the given MIDI file path.

        Args:
            file_path (str): The path to the MIDI file to be played.

        This constructor initializes the pygame mixer and loads the specified
        MIDI file for playback.
        """

        self.file_path = file_path
        self.init_pygame()

    def init_pygame(self):
        """
        Initialize pygame mixer and load MIDI file for playback.

        This method initializes the pygame mixer and loads the MIDI file
        specified during the initialization of the Player object. It is
        called automatically by the Player constructor.

        After calling this method, the pygame mixer is ready to play the
        loaded MIDI file using the play method.
        """
        
        pygame.mixer.init()
        pygame.mixer.music.load(self.file_path)

    def play(self):
        """
        Play the loaded MIDI file.

        This method starts the playback of the MIDI file that has been loaded
        during the initialization of the Player object. It prints a message
        indicating the start of playback and then plays the MIDI file using
        the pygame mixer.

        After initiating playback, the method waits for the playback to complete
        by calling wait_for_end().
        """

        print(f"Playing {self.file_path}...")
        pygame.mixer.music.play()
        
        self.wait_for_end()

    def wait_for_end(self):
        """
        Wait until the end of the current playback.

        This method waits until the currently playing MIDI file has finished
        playing. After playback is complete, the method prints a message to
        the console indicating that playback has completed.

        The method sleeps in 100ms intervals to check if the music has finished
        playing. This is to avoid CPU-intensive busy waiting.

        When playback is complete, the method prints a message to the console
        indicating that playback has completed.
        """
        
        while pygame.mixer.music.get_busy():
            
            time.sleep(0.1)
            
        print("Playback completed.")

    def quit(self):
        """
        Quit the pygame mixer and free up system resources.

        This method should be called when the Player object is no longer needed
        to free up system resources.
        """
        
        pygame.mixer.quit()


def play_midi_pygame(file_path):
    """
    Play a MIDI file using pygame.

    Args:
        file_path (str): The path to the MIDI file to be played.

    The function initializes a pygame mixer and loads the specified MIDI file
    for playback. If the file is not found, or an unexpected error occurs, an
    error message is printed to the console.

    After playback is complete, the function quits the pygame mixer to free up
    system resources.

    If an error occurs, the function prints an error message to the console and
    quits the pygame mixer.
    """
    
    player: Player | None = None
    
    try:
        
        player = Player(file_path)
        player.play()
        
    except pygame.error as e:
        
        print(f"Error playing the file: {e}")
        
    except FileNotFoundError:
        
        print(f"Error: The file '{file_path}' was not found.")
        
    except Exception as e:
        
        print(f"An unexpected error occurred: {e}")
        
    finally:
        
        if not (player is None):
        
            player.quit()

def play_midi_files():
    """
    Plays all MIDI files in the specified directory.

    This function iterates over all MIDI files in the MIDI_DIR directory,
    playing each file sequentially using the play_midi_pygame function.
    After each file is played, it waits for 1.5 seconds before proceeding
    to the next file.

    Note:
        The function assumes that the MIDI_DIR variable is defined and
        points to the directory containing the MIDI files.
    """

    for file in MIDI_DIR.glob("*.mid"):
        
        print(f"Playing {file.name}...")
        
        play_midi_pygame(file)
        
        print(f"Finished playing {file.name}.\n")
        
        time.sleep(1.5)

if __name__ == "__main__":
    """
    Main entry point of the script.
    It calls the play_midi_files function to start playing all MIDI files
    in the specified directory.
    """
    
    play_midi_files()