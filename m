From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH 1/3] powerpc: bare minimum
	checkpoint/restart	implementation
Date: Tue, 17 Mar 2009 07:55:37 +0100
Message-ID: <49BF4969.3080308@free.fr>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>	<1233182478-27113-2-git-send-email-ntl@pobox.com>	<49814FA2.9060108@cs.columbia.edu>
	<20090129214035.GB6913@localdomain>	<20090217010355.58afd5cf@thinkcentre.lan>	<49B9D37A.1070503@cs.columbia.edu>
	<20090316133745.4f636979@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090316133745.4f636979@thinkcentre.lan>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
To: Nathan Lynch <ntl@pobox.com>
Cc: containers@lists.osdl.org, Oren Laadan <orenl@cs.columbia.edu>, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org

> Again, how would 'cr' obtain exit status for these tasks, and how would
> it distinguish failure from normal operation?

Here's our solution to this issue.

mcr maintains in its kernel container object an exitcode attribute for 
the mcr-restart process. This process is detached from the fork tree of 
the restarted application.  

when the restart is finished, an mcr-wait command can be called to reap 
this exitcode. This make it possible to distinguish an exit of the 
application process from an exit of the mcr-restart process.

This is a must-have for batch managers in an HPC environment. 

Cheers,

C.
