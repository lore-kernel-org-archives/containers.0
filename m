From: corbet@lwn.net (Jonathan Corbet)
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Wed, 16 Jan 2008 07:23:40 -0700
Message-ID: <9803.1200493420@vena.lwn.net>
References: <478DFF8F.9030006@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755379AbYAPOXv@vger.kernel.org>
In-reply-to: Your message of "Wed, 16 Jan 2008 15:58:55 +0300."
             <478DFF8F.9030006@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, drepper@redhat.com, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi, Pavel,

[Adding Ulrich]

> I use the last bit in the clone_flags for CLONE_LONGARG. When set it
> will denote that the child_tidptr is not a pointer to a tid storage,
> but the pointer to the struct long_clone_struct which currently 
> looks like this:

I'm probably just totally off the deep end, but something did occur to
me: this looks an awful lot like a special version of the sys_indirect()
idea.  Unless it has been somehow decided that sys_indirect() is the
wrong idea, might it not be better to look at making that interface
solve the extended clone() problem as well?

jon
