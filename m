From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Wed, 28 Apr 2010 06:38:33 -0700
Message-ID: <87fx2f1yue.fsf@caffeine.danplanet.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
	<1272034539-19899-3-git-send-email-danms@us.ibm.com>
	<1272455094.14068.15.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1272455094.14068.15.camel@bigi> (jamal's message of "Wed\, 28 Apr 2010 07\:44\:54 -0400")
Sender: netdev-owner@vger.kernel.org
To: hadi@cyberus.ca
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

j> So ... how does user space know what "other_netns" is?

That's the point, userspace doesn't know about and can't use this
interface.  This is a way for the kernel to open a socket in another
netns to talk to that netns' RTNETLINK.  I realize in its current form
it could be used for something more nefarious, but it would be kernel
code doing it.

j> Also note Eric's recent patches introduced another way of opening a
j> socket in a different namespace - are you using those in the
j> abstraction to find what netns is?

No.  The process doing the checkpoint already has pointers to the
tasks and thus their netns pointers.  Eric's interface is an
abstraction to allow userspace to do something similar, I think that
using it from the kernel would be rather messy.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
