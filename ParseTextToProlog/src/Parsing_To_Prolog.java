import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

public class Parsing_To_Prolog {

	public static void main(String[] args) {
		
		String line;
		try{			
			//opening the file for input stream
			//provide the path of the input text file. (Complete path)
			InputStream file_input_reader = new FileInputStream("C:\\Users\\Ranjith\\Desktop\\Learning\\Netflow\\netflow.txt");
			BufferedReader br_input = new BufferedReader(new InputStreamReader(file_input_reader));

			//opening the file for output stream
			//provide the path of the output text file. (Complete path)
			FileOutputStream file_output_writer = new FileOutputStream("C:\\Users\\Ranjith\\Desktop\\Learning\\Netflow\\netflow_parsed_prolog.txt");
            BufferedWriter br_output = new BufferedWriter(new OutputStreamWriter(file_output_writer));
            
            
            //parsing netflow sample data into prolog facts
			while((line = br_input.readLine())!= null){				
				//int token = 0;
				String[] line_1=line.split(",");
				//Parsing the src address into double quotes format
				line_1[3] = "\""+line_1[3]+"\"";
				//parsing the dist address into double quotes
				line_1[6] = "\""+line_1[6]+"\"";
				//parsing state into small letters
				line_1[8] = line_1[8].toLowerCase();
				//parsing the label with double quotes
				line_1[14] = "\""+line_1[14]+"\"";
				
				//providing null values to empty fields
				for(int i=0; i<line_1.length;i++){
					if(line_1[i].equals("")){
						line_1[i] = null;
					}
				}
				//states - 8th token starting with indexes - append prolog at the start
				if(line_1[8].charAt(0) == '_'){
					line_1[8] = "prolog"+line_1[8];
				}
				
				//appending all the token back to the line
				StringBuilder build = new StringBuilder(100);				
				for(int i=0;i<line_1.length;i++){
					//avoiding "," for the last token
					if(i==14){
						build.append(line_1[i]);
					}
					else{
						build.append(line_1[i]+",");
					}
				}
				line = build.toString();				
				
				//adding predicate called netflow_facts to each line
				line = "netflow_Facts("+line+")."+"\n";	
				//System.out.println(line);
				//writing to the output file (netflow_parsed_prolog.txt)
				br_output.write(line);
				
			}
			//closing input reader stream
			br_input.close();
			//closing output reader stream
			br_output.close();
			//closing the input file stream
			file_input_reader.close();
			//closing the output file stream
			file_output_writer.close();
		}
		catch(FileNotFoundException F){
			System.out.println(F);
		}
		catch(IOException I){
			System.out.println(I);
		}

	}
}
