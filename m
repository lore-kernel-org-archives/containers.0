From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Wed, 23 Apr 2008 11:49:30 -0700
Message-ID: <m1tzhsmmo5.fsf@frodo.ebiederm.org>
References: <20080408215333.GA8799@us.ibm.com> <47FC138B.4070408@zytor.com>
	<1207779313.16926.12.camel@x61.ebiederm.org>
	<20080410015955.GA18227@sergelap.austin.rr.com>
	<1207812980.7509.25.camel@x61.ebiederm.org>
	<20080422142539.GA12623@sergelap.austin.ibm.com>
	<m1hcdtsovg.fsf@frodo.ebiederm.org>
	<20080423143610.GA13718@sergelap.austin.ibm.com>
	<20080423175749.GA17618@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755866AbYDWSt4@vger.kernel.org>
In-Reply-To: <20080423175749.GA17618@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Wed, 23 Apr 2008 12:57:49 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Containers <containers@lists.osdl.org>, clg@fr.ibm.com, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Serge E. Hallyn (serue@us.ibm.com):
>> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> > "Serge E. Hallyn" <serue@us.ibm.com> writes:
>> > >> 
>> > >> I'm hoping to be able to get back at this in the week or so as things
>> > >> settle down from my move.  My last patches should be in my proof of
>> > >> concept network namespace tree, if they don't show up elsewhere.
>> > >
>> > > Is that the tree I'd get from
>> > >
>> > > git-fetch
>> > > git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git
>> > > master:ebieder.master
>> > 
>> > Yes.
>> > 
>> > > ?  So I'd add a user_ns to the struct sysfs_tag_info?
>> > >
>> > > If so I'll give it a whirl.
>> > 
>> > Sounds good.  My apologies I keep being almost on the verge
>> > of getting someplace.
>> 
>> Ok I've got the sysfs relevant patches ported to 2.6.25, and am looking
>> at how to extend it to handle /sys/kernel/uids.  You have tagging tied
>> intimately to struct class.  So the question is should I generalize the
>> taggint to deal with kobjects instead, or create a struct class user
>> and make /sys/kernel/uids a symlink to /sys/class/user/uids?
>
> Heh, never mind, I was thinking class was a kobject class, not a device
> class  :)  So I'll just have to generalize tagging.

Yes.  You just need a way to get the tags there.

At the level of sysfs it is fairly general.
Getting through the kobject layer is a different story.

I suspect since you are working on this and I seem to be stuck
in molasses at the moment it makes sense to figure out what it
will take to handle the uid namespace before pushing these
patches again.

Taking a quick look and having a clue what we will need to
do for a theoretical device namespace is also a possibility.

Eric
