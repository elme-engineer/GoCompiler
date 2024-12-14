#include <stdlib.h>
#include <stdio.h>
#include "goast.h"

// WORK DONE BY:
// Pedro Bento 2021219351
// Ines Mendes 2017263654

// create a node of a given category with a given lexical symbol
struct node *newnode(enum category category, char *token) {
    struct node *new = malloc(sizeof(struct node));
    new->category = category;
    new->token = token;
    new->type = no_type;
    new->children = malloc(sizeof(struct node_list));
    new->children->node = NULL;
    new->children->next = NULL;
    return new;
}

// append a node to the list of children of the parent node
void addchild(struct node *parent, struct node *child) {
    struct node_list *new = malloc(sizeof(struct node_list));
    new->node = child;
    new->next = NULL;
    struct node_list *children = parent->children;
    while(children->next != NULL)
        children = children->next;
    children->next = new;
}

// get a pointer to a specific child, numbered 0, 1, 2, ...
struct node *getchild(struct node *parent, int position) {
    struct node_list *children = parent->children;
    while((children = children->next) != NULL)
        if(position-- == 0)
            return children->node;
    return NULL;
}

// count the children of a node
int countchildren(struct node *node) {
    int i = 0;
    struct node_list *temp = node->children;
    while (temp->next != NULL){
        i++;
        temp = temp->next;
    }
    return i;
}

// category names #defined in ast.h
char *category_name[] = names;

// traverse the AST and print its content
void show(struct node *node, int depth) {
    if (node == NULL){
        return;
    } 
    int i;
    for(i = 0; i < depth; i++)
        printf("..");

    if(node->token == NULL){
        printf("%s\n", category_name[node->category]);       
    }      
    else{

        printf("%s(%s)\n", category_name[node->category], node->token);
    }
    
    struct node_list *child = node->children;
    while(child != NULL){

        show(child->node, depth+1);
        child = child->next;
    }
}

void adoptChildren(struct node *newFather, struct node *sourceNode){

    struct node_list *aux_children = sourceNode->children;
    struct node_list *parent_children = newFather->children;

    while (parent_children->next != NULL)
    {
        parent_children = parent_children->next;
    }
    parent_children->next = aux_children->next;
}


// free the AST
void deallocate(struct node *node) {
    if(node != NULL) {
        struct node_list *child = node->children;
        while(child != NULL) {
            deallocate(child->node);
            struct node_list *tmp = child;
            child = child->next;
            free(tmp);
        }
        if(node->token != NULL)
            free(node->token);
        free(node);
    }
}