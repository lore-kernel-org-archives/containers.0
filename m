From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH][DOCUMENTATION] The namespaces compatibility list doc
Date: Fri, 16 Nov 2007 08:48:20 -0800
Message-ID: <20071116084820.cc8ccd19.randy.dunlap@oracle.com>
References: <473D6434.5020201@openvz.org>
	<473DBCC2.70506@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760814AbXKPQui@vger.kernel.org>
In-Reply-To: <473DBCC2.70506@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@osdl.org>, Theodore Tso <tytso@mit.edu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Fri, 16 Nov 2007 16:52:34 +0100 Daniel Lezcano wrote:

> > +1. Both the IPC and the PID namespaces provide IDs to address
> > +   object inside the kernel. E.g. semaphore with ipcid or
> > +   process group with pid.
> > +
> > +   In both cases, tasks shouldn't try exposing this id to some
> > +   other task living in a different namespace via a shared filesystem
> > +   or IPC shmem/message. The fact is that this ID is only valid
> > +   within the namespace it was obtained in and may refer to some
> > +   other object in another namespace.
> > +
> > +2. Intentionnaly, two equal user ids in different user namespaces
>        Intentionaly

        Intentionally,

> > +   should not be equal from the VFS point of view. In other
> > +   words, user 10 in one user namespace shouldn't have the same
> > +   access permissions to files, beloging to user 10 in another
>                                     belonging
> > +   namespace. But currently this is not so.
> > +

---
~Randy
