From: Pavel Emelyanov <xemul@parallels.com>
Subject: [Announce] Checkpoint-restore tool v0.1
Date: Mon, 23 Jul 2012 12:22:33 +0400
Message-ID: <500D09C9.7060903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lwn@lwn.net, "criu@openvz.org" <criu@openvz.org>
Cc: users@openvz.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi!

I'm glad to announce the first release of the checkpoint-restore tool.


This project is an attempt to implement the checkpoint-restore functionality
for processes and containers without driving too much code into the kernel tree,
but putting there "various oddball helper code" instead.

The tool can already be used for checkpointing and restoring various individual
applications. And the greatest thing about this so far is that most of the below
functionality has the required kernel support in the recently released v3.5!

So, we support now

* x86_64 architecture
* process' linkage
* process groups and sessions (without ttys though :\ )
* memory mappings of any kind (shared, file, etc.)
* threads
* open files (shared between tasks and partially opened-and-unlinked)
* pipes and fifos with data
* unix sockets with packet queues contents
* TCP and UDP sockets (TCP connections support exists, but needs polishing)
* inotifies, eventpoll and eventfd
* tasks' sigactions setup, credentials and itimers
* IPC, mount and PID namespaces

Though namespaces support is in there, we do not yet support an LXC container c/r,
but we're close to it :)


I'd like to thank everyone who took part in new kernel APIs discussions, the
feedback was great! Special thanks goes to Linus for letting the kernel parts
in early, instead of making them sit out of tree till becoming stable enough.


Tarball with the tool sources is at

  http://download.openvz.org/criu/crtools-0.1.tar.bz2

The git repo is at

  http://git.criu.org/

And some sort of docs growing at

  http://criu.org/


There are still things for which we don't have the kernel support merged (SysVIPC
and various anon file descriptors, i.e. inotify, eventpoll, eventfd) yet. We have
the kernel branch with the stuff applied available at

  https://github.com/cyrillos/linux-2.6.git


Thanks,
Pavel
