# -- LIBRARY -----------------------------------------------------------------
import sys
 
# -- LOCAL FILES -------------------------------------------------------------
from src.file_upload import FileUpload
 
def main(argv) -> None:
    
    file_list = ['file_one.txt', 'file_two.txt']
    
    # upload files to sftp
    if len(file_list) > 0:
        fp = FileUpload()
        fp.send_files(file_list=file_list)
 
 
# Start the program
if __name__ == '__main__':
    main(sys.argv[1:])
