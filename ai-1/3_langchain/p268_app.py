from langchain.memory import ConversationBufferWindowMemory

memory = ConversationBufferWindowMemory(k=2, return_messages=True)
memory.save_context({"input":"안녕"}, {"ouput":"무슨 일이야?"})
memory.save_context({"input":"배고파"}, {"ouput":"나도"})
memory.save_context({"input":"밥 먹자"}, {"ouput":"응. 그러자"})

print(memory.load_memory_variables({}))