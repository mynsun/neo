from langchain.prompts import PromptTemplate

no_input_prompt = PromptTemplate(
    input_variables = ["asjective", "content"],
    template = "{asjective} {content}이라고 하면?"
)

print(no_input_prompt.format(asjective="멋진", content="동물"))