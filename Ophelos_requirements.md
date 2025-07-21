# Software Engineer: Take Home (v3) Senior level (IO)

# 👋 Please complete this in your preferred (strongest) language.

<aside>
👉 An Income and expenditure (I&E) statement is a document that helps to understand someone's financial situation. It includes income (e.g., salary, benefits) and expenditure (e.g., rent, utilities) and can help assess whether repayments are affordable.

</aside>

## Your challenge

---

Build an API application that enables customers to create income and expenditure statements. This application should also calculate disposable income and provide an I&E rating of the customer.

Disposable income is calculated using the formula `D = income - expenditure`.

The I&E rating is determined by calculating the ratio `Ratio = expenditure / income` and then assigning a rating based on the following table:

| **Ratio** | **Grade** |
| --- | --- |
| Below 10% | A |
| 10% - 30% | B |
| 30% - 50% | C |
| Otherwise | D |

### **Requirements:**

<aside>
⭐ We have used the [MoSCoW method](https://en.wikipedia.org/wiki/MoSCoW_method) to prioritise these requirements and ensure that you stay within the allocated time frame

</aside>

- **Must** store the I&E statement in a database. *This doesn’t need to be fancy; a local database is fine.*
    - **Should** have a way to tell which person each I&E statement belongs to.
- **Must** calculate the disposable income and I&E rating
- **Must** have endpoints for the customers to create and retrieve an I&E statement
    - The authenticated customer **should** be able to define their income and expenditures on their statements.
- **Must** be well-tested
- **Should** return the disposable income and I&E rating for a statement
- **Could** respond in JSON
- **Could** have API documentation
- **Should** include unit tests
- [Mid-Senior] **Should** have authentication to secure the API endpoints.

Feel free to include any extra features that you see fit.

We expect this task to take 2 hours. However, if you have not built a server from scratch before, you may need to spend more time learning how to do that. You may use any frameworks and third-party libraries you like. Send your solution to us as a zip file or by providing a link to a repository that we can access. Include a README file with instructions on how to run the web app locally, a brief description of your thought process, and any improvements you would make.

---

## Reference

Example I&E statement:

| **Income** | **Amount** | **Expenditure** | **Amount** |
| --- | --- | --- | --- |
| Salary | 2800 | Mortgage | 500 |
| Other | 300 | Utilities | 100 |
|  |  | Travel | 150 |
|  |  | Food | 500 |
|  |  | Loan Repayment | 1000 |

Updated 21/06/2024
