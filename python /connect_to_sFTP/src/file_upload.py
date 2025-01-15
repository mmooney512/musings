# -- LIBRARY -----------------------------------------------------------------
import os
from pathlib import Path
 
import paramiko as pa
 
# -- LOCAL FILES -------------------------------------------------------------
from config import sftp_config
 
class FileUpload():
    def __init__(self) -> None:
        self._file_list: list = None
        self._ssh_client: pa.SSHClient = None
        self._sftp_client: pa.SFTPClient = None
        self._known_hosts_file_path: Path = None
 
        # set the file paths
        self.__set_file_paths()
 
    def __set_file_paths(self) -> None:
        self._known_hosts_file_path = os.path.normpath("".join([os.getcwd(),sftp_config.SERVER.KNOWN_HOSTS]))
 
        if os.path.isfile(self._known_hosts_file_path) == False:
            raise Exception(f"Known_Hosts file can't be found: {self._known_hosts_file_path}")
 
 
    def __connect_client(self) -> None:
        
        # get the ssh key
        sftp_key = pa.RSAKey.from_private_key_file(sftp_config.SERVER.KEY_FILENAME)
 
        # set the ssh client
        self._ssh_client = pa.SSHClient()
 
        self._ssh_client.load_host_keys(self._known_hosts_file_path)
 
        # connect to server
        self._ssh_client.connect(hostname=sftp_config.SERVER.HOSTNAME,
                                 username=sftp_config.SERVER.USERNAME,
                                 pkey=sftp_key)


    def send_files(self, file_list:list) -> None:
 
        # connect to ssh client
        self.__connect_client()
               
        # init the sftp client
        self._sftp_client = self._ssh_client.open_sftp()
 
        self._sftp_client.chdir(sftp_config.FILE.REMOTE_DIRECTORY)
        
        # cycle through each file and put them on server
        for file in file_list:
            local_file_path = os.path.join(file)
            remote_file_path = "".join([sftp_config.FILE.REMOTE_DIRECTORY, os.path.basename(file)])
            try:
                self._sftp_client.put(localpath=local_file_path,
                                      remotepath=remote_file_path)
            
            except FileNotFoundError as err:
                print(f"File {local_file_path} not found locally")
        
        self._sftp_client.close()
        self._ssh_client.close()
