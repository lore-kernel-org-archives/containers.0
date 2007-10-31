From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 0/5] A config option to compile out some namespaces code
 (v3)
Date: Wed, 31 Oct 2007 13:53:44 +0100
Message-ID: <47287AD8.9050607@fr.ibm.com>
References: <47285FEE.9030001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758821AbXJaMyE@vger.kernel.org>
In-Reply-To: <47285FEE.9030001@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
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
> When someone tries to clone some namespace with their support
> turned off, he will receive an EINVAL error.
> 
> This patchset can save more than 2KB from the vmlinux when
> turning the config option "NAMESPACES" to "n".
> 
> I do not introduce the NAMESPACES_EXPERIMENTAL config option, that
> switches all the namespaces we consider experimental, but each 
> namespace has its own config that can be mrked with "depends on
> EXPERIMENTAL" on demand.
> 
> This is mainly done because some people consider pid namespaces broken
> ant will probably want to make them depend on BROKEN. In this case
> we'll have to introduce the NAMESPACES_BROKEN option which is not that
> good.

I think the discussion finished with an 'immature' status :)
  
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I'm fine with all these patches and I have a bunch of patches that
depend on them already. The sooner they get in the better.

Thanks Pavel !

C.
