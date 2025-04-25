def nolambda(x, y):
    return 3 * x + 2 * y

x, y = 3, 5

yeslamda = lambda x, y: 3 * x + 2 * y

print(f'nolambda({x}, {y}) = {nolambda(x, y)}')
print(f'yeslamda({x}, {y}) = {yeslamda(x, y)}')