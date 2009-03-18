From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: C/R review
Date: Wed, 18 Mar 2009 05:44:19 -0400
Message-ID: <49C0C273.4070408@cs.columbia.edu>
References: <20090317210110.GA3897@x200.localdomain> <20090318004742.GA14308@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756264AbZCRJp3@vger.kernel.org>
In-Reply-To: <20090318004742.GA14308@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Alexey Dobriyan (adobriyan@gmail.com):
>>> +Keeping the restart procedure to operate within the limits of the
>>> +caller's credentials means that there various scenarios that cannot
>>> +be supported. For instance, a setuid program that opened a protected
>>> +log file and then dropped privileges will fail the restart, because
>>> +the user won't have enough credentials to reopen the file.
>> That's a bug.
> 
> What is described is not a bug, but I think the way it is done is in
> fact a bug.
> 
> Note that just because you *can* do the restart without privilege
> doesn't mean that you have to.  If you do a restart with privilege,
> then you should be able to open that file, then drop down to the
> original task's uid.
> 
> But to say that letting an unprivileged user do restart, and that
> it will only succeed if it can access the resources its allowed to
> access, is bogus.
> 
> But I do think the way it's implemented will become buggy and needs to
> be fixed.  That is, we do cr_read_task_struct() before we do
> cr_read_files().  So in fact if I'm root doing restart of such a
> checkpoint image, I'll first drop down to uid 500, then open the files.
> 
> That would obviously be a bug.
> 
> Now, we don't actually restore uids yet in the current code, so
> it's still a theoretical bug :)

Good point. And that's why uid's will be restored at the end :)
(when we get there ...)

Oren.
