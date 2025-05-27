from langchain.chat_models import ChatOpenAI
from langchain.schema import(
    SystemMessage,
    HumanMessage,
    AIMessage
)

chat_llm=ChatOpenAI(
    model = 'gpt-3.5-turbo',
    temperature = 0,
)

message = [
    HumanMessage(content="고양이의 울음소리는?"),
]
print('-' * 50)
result = chat_llm(message)
print(result)

prompts = ["고양이 울음소리는?", "까마귀 울음소리는?"]

for i, prompt in enumerate(prompts):
    message = [HumanMessage(content=prompt)]

    result = chat_llm(message)
    print('-' * 50)
    print(f"result {i} : {result.content}")