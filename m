From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [Announce] Checkpoint-restore tool v0.1
Date: Mon, 23 Jul 2012 08:14:19 -0500
Message-ID: <20120723131419.GB4923__35109.1758035638$1343049273$gmane$org@sergelap>
References: <500D09C9.7060903@parallels.com> <500D1116.7070301@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <500D1116.7070301-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, lwn-T1hC0tSOHrs@public.gmane.org, cgroups mailinglist <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> Fixing the bogus containers@ ml and adding cgroups@ one. Sorry :(
> 
> == Original message ==
> 
> Hi!
> 
> I'm glad to announce the first release of the checkpoint-restore tool.
> 
> 
> This project is an attempt to implement the checkpoint-restore functionality
> for processes and containers without driving too much code into the kernel tree,
> but putting there "various oddball helper code" instead.
> 
> The tool can already be used for checkpointing and restoring various individual
> applications. And the greatest thing about this so far is that most of the below
> functionality has the required kernel support in the recently released v3.5!
> 
> So, we support now
> 
> * x86_64 architecture
> * process' linkage
> * process groups and sessions (without ttys though :\ )
> * memory mappings of any kind (shared, file, etc.)
> * threads
> * open files (shared between tasks and partially opened-and-unlinked)
> * pipes and fifos with data
> * unix sockets with packet queues contents
> * TCP and UDP sockets (TCP connections support exists, but needs polishing)
> * inotifies, eventpoll and eventfd
> * tasks' sigactions setup, credentials and itimers
> * IPC, mount and PID namespaces
> 
> Though namespaces support is in there, we do not yet support an LXC container c/r,
> but we're close to it :)
> 
> 
> I'd like to thank everyone who took part in new kernel APIs discussions, the
> feedback was great! Special thanks goes to Linus for letting the kernel parts
> in early, instead of making them sit out of tree till becoming stable enough.
> 
> 
> Tarball with the tool sources is at
> 
>   http://download.openvz.org/criu/crtools-0.1.tar.bz2
> 
> The git repo is at
> 
>   http://git.criu.org/
> 
> And some sort of docs growing at
> 
>   http://criu.org/
> 
> 
> There are still things for which we don't have the kernel support merged (SysVIPC
> and various anon file descriptors, i.e. inotify, eventpoll, eventfd) yet. We have
> the kernel branch with the stuff applied available at
> 
>   https://github.com/cyrillos/linux-2.6.git
> 
> 
> Thanks,
> Pavel

Awesome - thanks, Pavel, and congratulations :)  I'll have to give it a
spin as soon as I get a chance.
