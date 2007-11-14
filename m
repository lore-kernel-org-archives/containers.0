From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/6] A config option to compile out some namespaces
	code (v4)
Date: Wed, 14 Nov 2007 08:58:46 -0600
Message-ID: <20071114145846.GC17106@sergelap.austin.ibm.com>
References: <473ADB5B.50902@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758760AbXKNO7V@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <473ADB5B.50902@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Cedric Le Goater <clg@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul@openvz.org):
> Change against v3: rebased on 2.6.24-rc2-mm1
> 
> There were some questions like "do I need this on my cellphone"
> in reply to different namespaces patches. Indeed, the namespaces
> are not useful for most of the embedded systems, but the code
> creating and releasing them weights a lot.
> 
> So I propose to add a config option which will help embedded
> people to reduce the vmlinux size. This option simply compiles
> out the namespaces cloning and releasing code *only*, but keeps
> all the other logic untouched (e.g. the notion of init_ns).
> 
> Moreover, some of the namespaces might be not 100% ready by
> the time of Linux-2.6.xxx release (like user namespaces or pid 
> namespaces are now). Since each namespace has its own option, 
> which depends on the NAMESPACES, it can be mrked with "depends
> on EXPERIMENTAL/BROKEN/ANYTHING_ELSE" not to release the
> functionality that is not 100% ready yet.
> 
> When someone tries to clone some namespace with their support
> turned off, he will receive an EINVAL error.
> 
> This patchset can save more than 2KB from the vmlinux when
> turning the config option "NAMESPACES" to "n".
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Pretty sure I did this a few versions ago, but

Acked-by: Serge Hallyn <serue@us.ibm.com>

for the whole set.

thanks,
-serge
