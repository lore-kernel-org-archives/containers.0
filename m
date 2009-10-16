From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v5)
Date: Fri, 16 Oct 2009 12:41:55 -0500
Message-ID: <20091016174155.GB10197@us.ibm.com>
References: <20091009205552.GA5778@us.ibm.com> <20091009205626.GA5823@us.ibm.com> <4AD7385A.8010902@librato.com> <20091015170630.GA25069@us.ibm.com> <4AD8A76A.8030201@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AD8A76A.8030201@librato.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@librato.com):
> > 4. Add a new field to the struct ckpt_obj which lets us store
> > the objref for the string pointer in the ckpt_obj for the void*.
> 
> Can you elaborate on what this entails ?
> 
> E.g., do you want to be able to store an arbitrary data field for
> an object, and add interface to set and get it ?  (If so, what is
> the proposed api ?)

Well we could do it either way - just make it a typeless field
that anyone coudl use as a sideband, or make it a signed int
only meant to be a link to another objref.

Don't much care about the API, but one way it could be used in
checkpoint_security() would be:

	objref = ckpt_obj_lookup_add(ctx, security, CKPT_OBJ_VOIDSEC, &new);
	if (!new)
		return ckpt_obj_getlink(ctx, objref);

	/* ... get the string context from the lsm and construct
	 * the struct ckpt_lsm_string */
	construct_lsm_string(ctx, &l, security, CKPT_SECTYPE_FILE);
	linkref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
	ckpt_obj_setlink(ctx, objref, linkref);
	return linkref;

But really, the only point of doing this is so that we can use
checkpoint_obj() instead of doing

	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SEC);
	ckpt_write_obj(ctx, &h->h);
	ckpt_hdr_put(ctx, h);
	ckpt_write_string(ctx, context_string, strlen(context_string)+1);

-serge

