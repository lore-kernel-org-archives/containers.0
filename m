From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 02 Mar 2010 14:10:06 +0100
Message-ID: <4B8D0E2E.6020205__46426.655635196$1267535456$gmane$org@free.fr>
References: <4B4F24AC.70105@trash.net>
	<m1wry46es9.fsf@fess.ebiederm.org>	<1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org>	<1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org>	<1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>	<4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org>	<4B883E6F.1060907@parallels.com>
	<m13a0nwu6p.fsf@fess.ebiederm.org>	<4B88D80A.8010701@parallels.com>
	<m1mxyvrqvk.fsf@fess.ebiederm.org>	<4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org>	<4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org>	<4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org>	<4B8AE8C1.1030305@free.fr>
	<m1ljebwwgd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ljebwwgd.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/01/2010 10:42 PM, Eric W. Biederman wrote:
> I am of two mind about my patches.  Right now they are a brilliant
> proof of concept that we can name namespaces without needing a
> namespace for the names of namespaces, and start to be a practical
> solution to the join problem.   At the same time, I'm not certain
> I like a solution that requires yet more syscalls so I ask myself
> is there not yet a simpler way.

thinking aloud,

what if you made the nsproxy a vfs_inode ? we could then mount the nsfs
to do all sorts of fs operations on the object, like notifying easily
its deletion. we would need to find a meaningful name, probably the inode
number.

one syscall (nsfd) would be required to get the nsproxy of a task (pid).
you can't guess that from an inode number.


C.
