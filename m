From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
 Vpid:)
Date: Thu, 16 Jun 2011 13:19:18 +0200
Message-ID: <1308223158.8230.66.camel@bahia.local>
References: <20110615145527.4016.70157.stgit@bahia.local>
	 <20110615190302.GA16440@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110615190302.GA16440@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Wed, 2011-06-15 at 21:03 +0200, Oleg Nesterov wrote:
> Forgot to ask,
> 
> On 06/15, Greg Kurz wrote:
> >
> > The need arises in the LXC community when one wants to send a signal from
> > the host (aka. init_pid_ns context) to a container process for which one
> > only knows the pid inside the container.
> 
> I am just curious, why do you need this?
> 

Because some LXC users run partially isolated containers (AKA.
application containers started with the lxc-execute command). Some of
the user code runs outside the container and some inside. Since
lxc-execute uses CLONE_NEWPID, it's difficult for the external code to
relate a pid generated inside the container with a task. There are
regular requests on lxc-users@ about this.

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
