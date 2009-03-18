From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: C/R review
Date: Tue, 17 Mar 2009 19:47:42 -0500
Message-ID: <20090318004742.GA14308@us.ibm.com>
References: <20090317210110.GA3897@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754657AbZCRAr5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090317210110.GA3897@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: orenl@cs.columbia.edu, lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan@gmail.com):
> > +Keeping the restart procedure to operate within the limits of the
> > +caller's credentials means that there various scenarios that cannot
> > +be supported. For instance, a setuid program that opened a protected
> > +log file and then dropped privileges will fail the restart, because
> > +the user won't have enough credentials to reopen the file.
> 
> That's a bug.

What is described is not a bug, but I think the way it is done is in
fact a bug.

Note that just because you *can* do the restart without privilege
doesn't mean that you have to.  If you do a restart with privilege,
then you should be able to open that file, then drop down to the
original task's uid.

But to say that letting an unprivileged user do restart, and that
it will only succeed if it can access the resources its allowed to
access, is bogus.

But I do think the way it's implemented will become buggy and needs to
be fixed.  That is, we do cr_read_task_struct() before we do
cr_read_files().  So in fact if I'm root doing restart of such a
checkpoint image, I'll first drop down to uid 500, then open the files.

That would obviously be a bug.

Now, we don't actually restore uids yet in the current code, so
it's still a theoretical bug :)

-serge
