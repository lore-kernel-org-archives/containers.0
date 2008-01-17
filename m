From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Thu, 17 Jan 2008 10:28:32 +0100
Message-ID: <478F1FC0.9020709@fr.ibm.com>
References: <478DFF8F.9030006@openvz.org> <9803.1200493420@vena.lwn.net> <20080117034844.GA27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755384AbYAQJbG@vger.kernel.org>
In-Reply-To: <20080117034844.GA27894@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jonathan Corbet <corbet@lwn.net>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, drepper@redhat.com, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Al Viro wrote:
> On Wed, Jan 16, 2008 at 07:23:40AM -0700, Jonathan Corbet wrote:
>> Hi, Pavel,
>>
>> [Adding Ulrich]
>>
>>> I use the last bit in the clone_flags for CLONE_LONGARG. When set it
>>> will denote that the child_tidptr is not a pointer to a tid storage,
>>> but the pointer to the struct long_clone_struct which currently 
>>> looks like this:
>> I'm probably just totally off the deep end, but something did occur to
>> me: this looks an awful lot like a special version of the sys_indirect()
>> idea.  Unless it has been somehow decided that sys_indirect() is the
>> wrong idea, might it not be better to look at making that interface
>> solve the extended clone() problem as well?
> 
> Nah, just put an XML parser into the kernel to have the form match the
> contents...
> 
> Al "perhaps we should newgroup alt.tasteless.api for all that stuff" Viro

so you'd rather have new syscalls to support new clone flags ? something
like :

	long sys_clone64(unsigned long flags_high, unsigned long flag_low)
	long sys_unshare64(unsigned long flags_high, unsigned long flag_low)

Thanks,

C.
