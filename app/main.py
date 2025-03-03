import streamlit as st
import ollama
import logging

# Logging and Logger Setup
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, handlers=[
        logging.FileHandler("debug.log"),
        logging.StreamHandler()
    ]
)
logger.info('Application started!')

st.write("Streamlit loves LLMs! 🤖 [Build your own chat app](https://docs.streamlit.io/develop/tutorials/llms/build-conversational-apps) in minutes, then make it powerful by adding images, dataframes, or even input widgets to the chat.")

st.caption("Just for learning; Connected with self-hosted Ollama")

models = [model["model"] for model in ollama.list()["models"]]
st.session_state["model"] = st.selectbox("Choose your model", models)

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [{"role": "assistant", "content": "Let's start chatting! 👇"}]

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Accept user input
if prompt := st.chat_input("What is up?"):
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})
    # Display user message in chat message container
    with st.chat_message("user"):
        st.markdown(prompt)

    # Display assistant response in chat message container
    with st.chat_message("assistant"):
        full_response = ""
        message_placeholder = st.empty()
        # Directly call ollama.chat with stream=True inside st.write_stream
        stream = ollama.chat(
            model=st.session_state["model"],
            messages=st.session_state["messages"],
            stream=True,
        )

        for chunk in stream:
            content = chunk["message"]["content"]
            full_response += content
            message_placeholder.markdown(full_response + "▌")
        message_placeholder.markdown(full_response)

        st.session_state.messages.append({"role": "assistant", "content": full_response})
