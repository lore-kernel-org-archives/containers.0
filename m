From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v5)
Date: Thu, 15 Oct 2009 12:06:30 -0500
Message-ID: <20091015170630.GA25069@us.ibm.com>
References: <20091009205552.GA5778@us.ibm.com> <20091009205626.GA5823@us.ibm.com> <4AD7385A.8010902@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AD7385A.8010902@librato.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@librato.com):
...
> > +	switch (sectype) {
> > +	case CKPT_SECURITY_MSG_MSG:
> > +		str = security_msg_msg_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_IPC:
> > +		str = security_ipc_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_FILE:
> > +		str = security_file_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_CRED:
> > +		str = security_cred_checkpoint(security);
> > +		break;
> > +	default:
> > +		str = ERR_PTR(-EINVAL);
> > +		break;
> > +	}
> 
> Let me suggest a different scheme (also last night's IRC); I think it's
> less hackish and uses better the existing {checkpoint,restore}_obj().
> 
> * Define one obj type CKPT_OBJ_SEC_{IPC, MSG_MSG, FILE, CRED}, with
> matching c/r functions security_{c,r}_{ipc,msg_msg,file,cred}_obj()
> 
> * Define one obj type for the string representation CKPT_OBJ_SEC_STR
> with matchin c/r functions security_{c,r}_string_obj()
> 
> * The helper will now:
> 
> 	security_checkpoint_obj()
> 	{
> 		switch (type) {
> 		case CKPT_OBJ_SEC_IPC:
> 			ret = checkpoint_obj(ctx, sec, CKPT_OBJ_SEC_IPC);
> 			break;
> 		case CKPT_OBJ_SEC_CRED:
> 			ret = checkpoint_obj(ctx, sec, CKPT_OBJ_SEC_CRED);
> 		...
> 	}
> 
> 	security_checkpoint_ipc_obj()
> 	{
> 		...
> 		ckpt_lsm_str = str_from_sec_ipc();   /* like you do now */
> 		objref = checkpoint_obj(ctx, ckpt_lsm_str, CKPT_OBJ_SEC_STR);
> 		...
> 		h->objref = objref;
> 		ckpt_write_obj();
> 	}
> 
> Perhaps a variation on this where the string is checkpoint_obj()'ed
> first would also work.
> 
> I haven't looked at all the details, but I hope something along these
> lines would help untangle the current mess.

So as discussed on irc, that by itself won't work bc (a) smack
will checkpoint the same void* as multiple objtypes, and the
objhash will complain.

Since we've gone over several possibilities on irc, let me summarize
some here:

1. do the restore_security() in the code instead of using an objref
to have it called automatically.  That stops me having to write an
objref by hand before writing out the CKT_HDR_CRED.  That's fine
with me, but then I won't be using checkpoint_obj() either, so I
want to make sure I'm not going to change all the restore callers
just to end up nixing that path.

2. alter the objhash to not complain if the same void* is checkpointed
as a different type.  That may have safety implications for the rest
of the objhash users, especially at restart where we can't really trust the
input.

3. have security_checkpoint_obj() 'reserve' a dummy objsec by
stuffing the void* security, then assume that the objref for
the string representation will be objref(void*security)+1.
This might cause problems if we later parallelize checkpoint so
that objref+1 is no longer valid.

4. Add a new field to the struct ckpt_obj which lets us store
the objref for the string pointer in the ckpt_obj for the void*.

For completeness, the latest version which I actually sent out
did:

5. Define two objhash object types for the lsm obj, one to
use at checkpoint, and one at restart.  At checkpoint, it
stuffs the void* security into the objhash and manually writes
out a checkpoint entry for the context string.  At restart, it
places a struct containing the context string in the objhash.
The type used at restart must have ->get/->drop defined so that
the struct is freed at the end of restart, while at checkpoint
we can't hvae ->get/->drop bc the void* is opaque (and persistand
relative to the checkpoint operation).

And what I was starting on until the latest irc conversation
was (3).

At the moment (4) seems to me like the best path.

-serge
