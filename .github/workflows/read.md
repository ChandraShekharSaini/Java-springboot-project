```yaml
# ============================================================
# 1. WORKFLOW
# ============================================================

name: Java CI/CD Pipeline


# ============================================================
# 2. TRIGGER / EVENT
# ============================================================

on:
  push:
    branches:
      - main

  pull_request:
    branches:
      - main

  workflow_dispatch:


# ============================================================
# 3. VARIABLES
# ============================================================

env:
  APP_NAME: my-java-app
  JAVA_VERSION: '21'
  AWS_REGION: us-east-1


# ============================================================
# 4. JOBS
# ============================================================

jobs:


  # ==========================================================
  # JOB 1: BUILD
  # ==========================================================

  build:

    # 5. RUNNER
    runs-on: ubuntu-latest

    # 13. MATRIX
    strategy:
      matrix:
        java: ['17', '21']

    steps:

      # 6. STEP + 7. ACTION + 8. USES
      - name: Checkout source code
        uses: actions/checkout@v4


      # Cache dependencies
      - name: Cache Maven dependencies
        uses: actions/cache@v4
        with:
          path: ~/.m2/repository
          key: maven-${{ runner.os }}-${{ hashFiles('**/pom.xml') }}
          restore-keys: |
            maven-${{ runner.os }}-


      # Setup Java
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: ${{ matrix.java }}
          distribution: temurin
          cache: maven


      # 9. RUN
      - name: Build application
        run: mvn clean package


      # Run tests
      - name: Run tests
        run: mvn test


      # ======================================================
      # 10. ARTIFACT
      # ======================================================

      - name: Upload JAR artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.APP_NAME }}-jar
          path: target/*.jar


  # ==========================================================
  # JOB 2: DEPLOY
  # ==========================================================

  deploy:

    # 11. ENVIRONMENT
    environment: production

    runs-on: ubuntu-latest

    # 12. NEEDS
    needs: build

    # 14. IF
    if: github.ref == 'refs/heads/main'

    steps:

      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ env.APP_NAME }}-jar


      # ======================================================
      # 15. SECRETS
      # ======================================================

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}


      # ======================================================
      # RUN COMMAND
      # ======================================================

      - name: Deploy application
        run: |
          echo "Deploying $APP_NAME"
          echo "Region: $AWS_REGION"
          echo "Deployment completed"
```
