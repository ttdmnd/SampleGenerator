from musicpy.structures import note
from musicpy.musicpy import write

from pathlib import Path

def generate_note(note_name: str, octave: int) -> note:
    """
    Generate a note with the specified parameters.

    Args:
        note_name (str): The name of the note (e.g., 'C4', 'A#5').

    Returns:
        Note: A musicpy Note object representing the generated note.
    """
    
    return note(
        
        name=note_name, 
        num=octave, 
        duration=1, 
        volume=100,
        
    )

def generate_midi_note(given_note: note, octave: int) -> None:
    """
    Generate a MIDI file containing the given note.

    Args:
        given_note (Note): The note to be converted to a MIDI file.

    Returns:
        None
    """
    
    write(
        given_note, 
        name=str(
            (Path(__file__).parent.parent.parent.parent.parent / "midi-samples" /
            given_note.standard_name()).absolute()
        ) + str(octave) + ".mid",
        instrument=1, 
        save_as_file=True
    )
    
class NoteGenerator:
    """
    A class to generate and handle musical notes.
    """
    
    # A list of musical notes, including sharp and flat notes.
    NOTES: list[str] = [
        'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    ]
    
    """
    A list of octaves to generate notes for.
    This will generate notes from C1 to B7.
    The range can be adjusted as needed.
    """
    OCTAVES: list[int] = [1, 2, 3, 4, 5, 6, 7]

    def __init__(self) -> None:
        """
        Initialize a NoteGenerator object.

        On initialization, this object will generate all 12 notes across 7 octaves
        and save them as MIDI files.

        Notes are named according to the format 'C4', 'G#5', 'A2', etc. The MIDI
        file for a given note will be saved with the same name as the note but
        with a '.mid' extension.

        Example: The note 'C4' will be saved as 'C4.mid'.
        """
        
        for octave in self.OCTAVES:
            
            for note_name in self.NOTES:
                
                note_obj = generate_note(note_name, octave)
                
                generate_midi_note(note_obj, octave)
    
if __name__ == "__main__":
    """
    Main entry point for the script.
    
    When run as a script, this will create an instance of NoteGenerator,
    which will generate all notes and save them as MIDI files.
    """
    
    NoteGenerator()
        
