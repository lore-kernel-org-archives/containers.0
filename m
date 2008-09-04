From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 7/9] Infrastructure for shared objects
Date: Thu, 04 Sep 2008 11:14:22 -0700
Message-ID: <1220552062.23386.35.camel__21642.2336445705$1220552286$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040404550.5982@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040404550.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-09-04 at 04:05 -0400, Oren Laadan wrote:
> +=== Shared resources (objects)
> +
> +Many resources used by tasks may be shared by more than one task (e.g.
> +file descriptors, memory address space, etc), or even have multiple
> +references from other resources (e.g. a single inode that represents
> +two ends of a pipe).
> +
> +Clearly, the state of shared objects need only be saved once, even if
> +they occur multiple times. We use a hash table (ctx->objhash) to keep
> +track of shared objects in the following manner.
> +
> +On the first encounter, the state is dumped and the object is assigned
> +a unique identifier and also stored in the hash table (indexed by its
> +physical kenrel address). From then on the object will be found in the
> +hash and only its identifier is saved.
> +
> +On restart the identifier is looked up in the hash table; if not found
> +then the state is read, the object is created, and added to the hash
> +table (this time indexed by its identifier). Otherwise, the object in
> +the hash table is used.
> +
> +The interface for the hash table is the following:
> +
> +int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type);
> +  [checkpoint] find the unique identifier - object reference (objref)
> +  - of the object that is pointer to by ptr (or 0 if not found).
> +
> +int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
> +                  unsigned short type, unsigned short flags);
> +  [checkpoint] add the object pointed to by ptr to the hash table if
> +  it isn't already there, and fill its unique identifier (objref); will
> +  return 0 if already found in the has, or 1 otherwise.
> +
> +void *cr_obj_get_by_ref(struct cr_ctx *ctx, int objref, unsigned short type);
> +  [restart] return the pointer to the object whose unique identifier
> +  is equal to objref.
> +
> +int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
> +                  unsigned short type, unsigned short flags);
> +  [restart] add the object with unique identifier objref, pointed to by
> +  ptr to the hash table if it isn't already there; will return 0 if
> +  already found in the has, or 1 otherwise.

Once you get to the point of putting function prototypes in
Documentation/, it's probably a good time to start using kerneldocs. :)

-- Dave
