# pages / 3_delete_row.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st

# -- LOCAL -------------------------------------------------------------------
from streamlit_handler import StreamlitDeleteData

def main():
    st.set_page_config(layout="wide")
    # INIT
    if 'data_editor_delete' not in st.session_state:
        st_handler = StreamlitDeleteData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler']     

    # layout
    st.header("Delete Rows")
    
    # select box UI for which table
    selected_table = st_handler.selectbox_table()

    if selected_table is not None:
        # Tell user what to do
        st.text("Check box in Select column to mark row for deletion")
        st_handler.source_table_name = selected_table
        st_handler.total_pages = st_handler.fetch_row_count()

        with st.sidebar:
            # Dropdown to select rows per page
            st_handler.selectbox_rows_per_page()
            
            # input box to select page number
            st_handler.input_page_select()

        # page nav controls
        st_handler.page_nav_controls()

        # source table data
        table_data = st_handler.data_editor_formatted()

        # delete the data from the table
        st.button(label="Delete Rows",
                  key="btn_delete_rows",
                  on_click=st_handler.prompt_for_confirmation,
                  args=(table_data.query("Select == True").shape[0],)
                  )
        
        if st_handler.deletion_requested:
            # delete the data from the table
            st.button(label="Confirm Deletion",
                    key="btn_confirm_delete",
                    on_click=st_handler.delete_source_data,
                    args=(table_data.query("Select == True"),))
        
        if st_handler.query_success():
            # let user know rows have been deleted
            st.success("Selected rows deleted successfully.")
            table_data['Select'] = False

        st.session_state['st_handler'] = st_handler


if __name__ == "__main__":
    main()