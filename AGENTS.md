AGENTS Pipeline Guide
Introduction

This guide provides a comprehensive pipeline for an AI agent to autonomously tackle a machine learning challenge using first-principles reasoning. By following this AGENTS.md, the agent should be able to understand the problem context, prepare data, select and train an appropriate model (likely XGBoost for tabular data), evaluate results, iterate on improvements, and finally generate a run.sh script for execution. All instructions here are derived from the challenge context – no external assumptions or constraints beyond those given in the repository should be introduced. The agent must focus on first-principle thinking, breaking down the problem fundamentally, and avoid getting stuck in loops of repetitive logic. If progress stalls, the agent should step back, rethink from a different angle, and then continue. We also outline safeguards to ensure the agent can pause, self-reflect, and adjust strategy as needed. Throughout the process, the agent will document important insights and any assumptions, and record lessons learned in a lessons_learned.md for future reference and improvement of this guide.

Pipeline Steps
Step 1: Context Gathering and Understanding the Challenge

Read the Challenge Description: Begin by thoroughly reading the challenge documentation in the repository (e.g. README, data description files, or any provided context). Identify the objective (e.g. is it a classification or regression problem? what is the target variable?), the evaluation metric (accuracy, AUC, etc.), and any domain-specific details or constraints (e.g. feature descriptions, data limitations, or rules of the competition).

Identify Available Data: Determine what datasets are provided (training set, validation set, test set). Note their file paths and formats (CSV, JSON, etc.). If a separate test set is given without labels (common in competitions), understand that you will need to train on the training data and perhaps validate on a portion of it.

Extract Relevant Constraints: Check if the challenge imposes any specific constraints (time limits, model size limits, allowed libraries, etc.). Also confirm if the use of certain techniques is encouraged or prohibited. Do not assume anything not stated – adhere strictly to the information given.

Plan Based on Context: Summarize the problem in your own words (internally) and formulate an initial plan. For example: “We need to predict X using features A, B, C... The data size is N, and metric is accuracy, so we should consider balancing classes if needed,” etc. Ensure you understand the end goal (e.g., produce a CSV of predictions for submission or just report accuracy on a validation set).

Step 2: Data Preparation and Exploration

Load Data: Implement code to load the dataset(s) using appropriate libraries (e.g. pandas for CSV). Ensure the file paths are correct as per the repository structure.

Exploratory Data Analysis (EDA): Briefly examine the data to understand its structure:

Print or log the shape of the datasets (number of rows, columns) and column names.

Check for missing values or inconsistent data. If found, decide on a strategy (e.g. impute with mean/median for numeric, mode for categorical, or drop if appropriate).

Look at basic statistics for numeric features and frequency counts for categorical features to spot anomalies.

Identify data types (so you know which features may need encoding or normalization).

Feature Engineering (if applicable): If the context or your EDA suggests it, plan for any feature transformations:

Convert categorical variables to numeric via encoding (one-hot, label encoding) if required by the model.

Scale or normalize features if needed (though tree-based models like XGBoost often handle raw ranges well, normalization might not be necessary unless specified).

Create new features only if you have a clear hypothesis they will help and if it aligns with first-principles understanding of the problem domain. Keep it simple for the first iteration.

Split Data for Validation: If no separate validation set is provided, split the training data into training and validation subsets (for example, an 80/20 split, ensuring the split is random but stratified if classification to maintain class balance). This will allow you to test the model’s performance before finalizing. Use a fixed random seed for reproducibility.

Step 3: Model Selection and Training

Choose the Model: Select a model based on the data characteristics and challenge requirements. For most structured data challenges, XGBoost is a strong choice given its performance and versatility. (If the challenge or data suggests otherwise – e.g., a simpler linear model or a neural network if data is very large – you may choose differently. But proceed with XGBoost as the default unless a clear reason to use another model arises.)

Justify the Choice (Internally): Ensure you have a rationale for the model choice grounded in first principles:

e.g. “XGBoost can handle nonlinear relationships and feature interactions out-of-the-box, and it’s robust to different scales and missing values, which fits our data characteristics.”

If using a different model, reason about why it’s suitable (e.g. “A random forest might be sufficient and quicker for this dataset size,” or “A linear model might work due to high dimensional sparse data,” etc.).

Set Up Training Parameters: Use clear and deterministic defaults to start:

For XGBoost, initialize with sensible default hyperparameters (e.g. max_depth, eta/learning_rate, n_estimators/iterations, etc.). XGBoost’s default parameters are often reasonable, but you might set a moderate number of trees (e.g. 100-200) for a quick baseline run.

If the challenge metric is known (say AUC for imbalanced classes), consider setting the objective and evaluation metric accordingly in the model (e.g. objective="binary:logistic" and use eval_metric="auc" for XGBoost in a binary classification for ROC AUC).

Use a random seed for model training (random_state or seed) for reproducibility.

Train the Model: Write code to train the model on the training data:

If using XGBoost via its sklearn API (XGBClassifier or XGBRegressor), call model.fit(X_train, y_train, early_stopping_rounds=… , eval_set=[(X_valid, y_valid)] …) if a validation set is available, to prevent overfitting. Use early stopping with a reasonable number of rounds (e.g. 10) to halt training when no improvement.

If using the XGBoost library directly, prepare a DMatrix and use xgb.train similarly with evaluation monitoring.

Print or log training progress (especially if using early stopping, log the validation score each iteration to verify the model is learning).

Ensure no errors occur (like dimension mismatches or data type issues) and handle them if they do (e.g. convert DataFrame to numpy array, etc., as needed).

Step 4: Model Evaluation and Testing

Evaluate on Validation Data: After training, use the model to predict on the validation set (or a test set if provided with ground truth for internal evaluation). Collect metrics:

Calculate the primary evaluation metric (accuracy, AUC, RMSE, etc. as per the challenge) on the validation predictions.

Also consider other relevant metrics for a fuller picture (e.g. precision/recall for classification if class imbalance is a concern, etc.), even if they are not the challenge metric, to understand model behavior.

Print or log these metrics in a clear format for analysis.

Review Results: Analyze the model’s performance:

Is the score reasonable relative to what the context or baseline expectations are (if any baseline is mentioned in the challenge)?

Check if the model is overfitting: compare training vs validation performance. If training score is much higher than validation, overfitting might be an issue.

If underfitting (both training and validation scores are low), the model may be too simple or not trained enough.

Save Predictions (if required): If the challenge expects a submission on a test set without labels, use the trained model to predict on the test dataset and save these predictions to a CSV file in the required format. Ensure you follow any submission format exactly (e.g. include an ID column if needed, and the prediction column with correct naming).

Document Any Findings: Make a note (internally or in lessons_learned.md draft) of any interesting findings from this run. For example, “Feature X had a large impact as seen by feature importance,” or “Model had trouble with a certain class of instances,” etc. This will guide improvements in the next iteration.

Step 5: Iteration and Improvement

Identify Improvement Areas: Based on the evaluation:

If performance is not satisfactory or could be better, analyze what might improve it. Return to first principles: consider data, model, and algorithmic aspects.

Examine feature importances (if using XGBoost or tree-based model, you can get feature importance scores) to see which features are influential or if any important feature was neglected.

Analyze errors: look at some examples where the model’s predictions were wrong (if possible) to identify patterns (e.g. certain categories consistently mispredicted).

Brainstorm Solutions: Come up with hypothesis-driven ideas to improve:

Data-related: Does the data need cleaning or transformations (outliers removal, better handling of missing values)? Would new features help (ratios, combinations, datetime breakdowns, etc.)?

Model-related: Would tuning hyperparameters improve generalization (e.g. reducing max_depth to avoid overfitting, increasing n_estimators, adjusting learning rate)? Would a different model or an ensemble of models perform better?

Algorithmic: Would cross-validation yield a more robust estimate and use data more effectively than a single hold-out validation? Consider implementing k-fold CV if appropriate.

Implement One Change at a Time: To scientifically determine impact, avoid changing too many things at once. Iteratively:

Apply one improvement (e.g. add one new feature or adjust a hyperparameter), retrain the model, and evaluate again.

Compare the new results with the previous iteration. If it helped, keep the change; if not, consider reverting or trying a different approach.

Keep notes of each change and its effect in the lessons_learned.md or internally, to track what works and what doesn’t.

Loop Through Iterations: Continue this cycle of propose-change -> implement -> evaluate for a few iterations or until you reach a satisfactory performance or hit diminishing returns. Always ground your changes in reasoning (why you expect them to help) and verify the outcome.

Remember to stay within the challenge’s constraints (e.g., if there’s a time limit, adding extremely slow models or exhaustive hyperparameter searches may not be feasible).

If you reach a point where improvements are minor or you're satisfied with the model’s performance relative to the challenge expectations, proceed to finalizing the solution.

Step 6: Finalizing and Generating run.sh

Compile Final Solution Steps: Once you have a solution approach locked down (after iterations), consolidate the necessary steps (data prep, model training, prediction generation) into a single pipeline. The goal is to produce a script run.sh that can be executed to reproduce the results from scratch.

Create the run.sh Script: The agent should now generate a deterministic shell script (or an executable script in the environment) that automates the full pipeline:

The script should perform any required data download or extraction if applicable, then run the data preparation (e.g. calling a Python script or Jupyter notebook that handles preprocessing), then training, and finally output the results (model artifacts or prediction files).

Ensure the script sets up any needed environment (for example, installing specific Python packages or setting environment variables) if that’s part of the process. However, prefer to assume the environment already has necessary dependencies (like XGBoost, pandas, etc.) unless the challenge explicitly requires installation steps.

Make the script as simple as possible for the end-user: for instance, it might call a Python file train_and_predict.py with all logic, or directly contain command-line calls to run training and inference.

Include comments in the script for clarity if needed, but focus on reliable execution. The agent should avoid any interactive prompts or requiring human input – everything should be hard-coded or configured based on earlier steps.

Test run.sh End-to-End: Simulate running the run.sh pipeline (the agent can mentally step through it or actually execute if environment allows) to ensure it works:

Does it correctly load data and produce the same evaluation results achieved in the notebook/interactive experimentation?

Are all file paths correct and relative (so that it works when someone else runs it in the repository context)?

If possible, catch any errors and fix them now (for example, missing permissions on the script, missing dependencies, etc.).

The run.sh should ideally echo or output key progress messages or results to confirm it ran successfully.

Finalize Outputs: Make sure all required output files (e.g. final predictions file for submission, or model metrics) are generated by the pipeline. The agent should not rely on anything that was done manually – the script should cover all needed steps. Once verified, the solution is considered ready.

Step 7: Logging Lessons Learned and Next Steps

Create/Update lessons_learned.md: After completing the challenge solution, the agent must log its experiences. Open or create a lessons_learned.md in the repository and record:

A brief summary of the final approach and why it was chosen (e.g. “Used XGBoost with early stopping, plus two additional features, which improved AUC from A to B.”).

Key challenges encountered and how they were overcome (e.g. “Initial model was overfitting, reduced max_depth to mitigate.” or “Had a bug reading data, fixed by ensuring correct delimiter.”).

Mistakes made or things that didn’t work, and what was learned from them (“Tried a neural network which performed worse – learned that it’s not always better for tabular data given limited data size.”).

Any assumptions or clarifications the agent had to make during execution (“Assumed missing values can be imputed with median; no instructions given on that in challenge.”).

Ideas for further improvement if there was more time or for future similar projects.

Keep it Shareable: Write the lessons learned in a way that other humans (or agents) reading the file can understand and use to improve future pipelines. This will help maintainers refine the AGENTS.md and overall approach for the next runs.

Review and Update Instructions (if applicable): If during the process the agent realized some parts of this AGENTS.md were unclear or insufficient, note this as well. The maintainers can update this guide for clarity. However, the agent itself should not modify AGENTS.md on this run, only provide feedback in lessons_learned.md. Future iterations of the guide will incorporate those improvements.

Finalize Submission: If the challenge involves a submission (like to a competition leaderboard), ensure that the submission file from run.sh is ready and properly formatted. Document the submission process if needed (though the agent typically does not handle the actual website submission, it should note if there's anything special about it).

Agent Guidelines and Safeguards

Precise and Unambiguous Following of Instructions: The agent should strictly adhere to the steps above. If any instruction seems vague or conflicting, the agent must not arbitrarily guess; instead, it should interpret it in a reasonable way consistent with the rest of the guide. (For example, if one part of context says one thing and another part differs, carefully reconcile them using logic and choose the most sensible interpretation.)

Appropriate Reasoning Effort: Apply the right level of reasoning to each task. Use high reasoning effort for complex decisions (e.g. selecting models, diagnosing issues, designing improvements) to thoroughly analyze possibilities. For straightforward tasks, avoid overthinking; a medium or low reasoning level is sufficient to execute clearly defined steps. This ensures efficiency and prevents the model from getting bogged down in trivial details.

Avoid Unnecessary Firmness or Redundancy: The instructions in this guide are meant to be followed diligently, but the agent should not overdo any step beyond its purpose. For example, “be thorough in gathering information” does not mean entering an infinite loop of data exploration. It means to gather enough context to proceed confidently, then move on. Do not repeatedly restate or re-confirm the same information; trust the process and only revisit steps if new information or an issue arises.

Structured Thought Process: The agent can benefit from structuring its internal reasoning. Breaking down the plan (as done in this guide with steps) is encouraged. If helpful, the agent can internally use a structured format (even XML-like syntax or pseudo-code) to outline sub-tasks before executing them. This is akin to planning out loud. It’s not mandatory to output such planning to the user, but doing it internally can ensure no aspect of the problem is overlooked. For instance, the agent might internally enumerate: <plan>First load data -> Then check data -> Then model...</plan> as a mental model to stay organized.

Focus on First Principles: Always come back to the fundamental question: what are we trying to achieve and what do we know for sure? If the agent faces a decision, ground it in basic reasoning:

e.g. “Our goal is to predict X; fundamentally, a model will learn patterns to map features to X. What pattern could we be missing? Do we need a new feature to capture that?”

This approach prevents blindly following heuristics and encourages creative, sound solutions. The agent should not rely on “this worked before” without justification – it should understand why something might work here.

Self-Reflection and Flexibility: It’s important the agent periodically assesses its own progress. After each major step or when stuck, ask: “Is this approach working? If not, why?”. Don’t hesitate to adjust the plan if evidence suggests a different path would be better.

<self_reflection>

Before jumping into writing code or executing steps, take a moment to plan and reflect. For example, internally outline the solution approach (like pseudocode or a checklist) and examine if it covers all requirements. This ensures confidence in the plan.

Consider what a successful outcome looks like (e.g. high validation score, or a valid submission file) and ensure your plan aims towards that. If any part of the plan seems weak, rethink it now rather than after implementation.

During execution, if you encounter a problem (like a surprising data issue or a model not learning well), pause to reason about the root cause. It’s better to spend a bit more time reasoning or debugging than to charge forward with a flawed approach.

After completing the task, reflect on the overall process. Identify if there were inefficiencies or avoidable mistakes in your approach. This will be useful information to log in the lessons_learned.md.
</self_reflection>

Avoid Logic Loops: If you find yourself circling around the same idea without making progress (for instance, toggling a parameter back and forth without clear improvement, or re-reading the same context without new insights), recognize this and break out of the loop. Step away mentally, revisit the core objective, and try a fundamentally different strategy. Sometimes explaining the problem to yourself as if to another person or simplifying the problem can help break the loop. The guide’s structure should prevent most loops, but the agent must be self-aware to not get stuck in a futile cycle.

Persistence and Assumption Handling: The agent should be persistent in reaching a solution, but this persistence should be channeled into productive exploration, not repeating the same failing approach.

<persistence> - Do **not** ask the human user for additional guidance or confirmation during the run. You have all the information needed in this file and repository context. If something is unclear, make a reasonable assumption based on the given context and proceed. You can always adjust later if needed. - For each assumption made, clearly note it down (for example, add a comment in code or mention in `lessons_learned.md`: e.g. “Assumed that missing values can be filled with median since not specified.”). This way, if the assumption was wrong, it can be corrected in future iterations, and the user will be aware of it. - Keep trying different angles if the first solution attempt doesn’t meet expectations. Do not give up easily; however, ensure each new attempt is informed by learning from the previous attempt (don’t just try random changes). - The goal is to produce a working solution autonomously. Use the tool (coding, training, evaluating) as much as needed, but avoid unnecessary steps that don’t bring new information. Every action should move you closer to the end goal. </persistence>

Communication and Logging: Even though the agent isn’t directly chatting with a user during the autonomous run, it should maintain good “communication” habits via logging:

Print or record important milestones, decisions, and results. For instance, logging “No missing values found, skipping imputation” or “Validation AUC = 0.8423” is helpful for anyone reviewing the agent’s run output.

If something goes wrong, the logs should make it easier to pinpoint where. (This is also crucial for the agent itself to debug issues during the run.)

In the final lessons_learned.md, communicate in a clear and concise manner what was done and learned, as if explaining to a colleague. This will greatly help in improving future agent instructions.

By following this pipeline and guidelines, the agent should be able to autonomously read the context, devise a solution, create and test an XGBoost (or chosen model) pipeline, iterate on improvements, and output a ready-to-run run.sh script, all while documenting its journey. The above safeguards and structured approach ensure that the agent stays on track, thinks critically from first principles, and avoids common pitfalls such as infinite loops or shallow pattern-matching. This AGENTS.md is designed to be the single resource needed for the agent to succeed in the challenge – an ironclad guide for robust autonomous problem-solving. Good luck, and happy modeling!
