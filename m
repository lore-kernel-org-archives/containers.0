From: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Thu, 28 May 2015 22:06:17 +0200
Message-ID: <1432843577.9873.1.camel__2399.95505330644$1432843593$gmane$org@redhat.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
	<1427807248.2117.117.camel@HansenPartnership.com>
	<CALCETrWKA4ZdHfdLuW0_W5xxJOSCJdt_fiRWs6vDk+8ZQ9n9iA@mail.gmail.com>
	<1427808184.2117.122.camel@HansenPartnership.com>
	<CALCETrW8v1NFa7fcJbyJKXk9Msudht5BJ7Zy1Rg7ZC_TS-2Y-Q@mail.gmail.com>
	<1427810118.2117.126.camel@HansenPartnership.com>
	<CALCETrU1vKf3fXPt8nS-ABDgfp8NxrFjHwTc68rA0rtvg2Lufg@mail.gmail.com>
	<1427810886.2117.129.camel@HansenPartnership.com>
	<1427811444.4411.20.camel@redhat.com>
	<1427969525.3559.120.camel@HansenPartnership.com>
	<CALCETrWyUYgHY53O451AdJUs9Mcjsqmr4fUzoNmYsTP1HLq+VA@mail.gmail.com>
	<1427984969.13651.11.camel@redhat.com>
	<CALCETrWYit+WiAM6DFm0enGeJN==uWNC63zXp_zRSsSJg2YGPg@mail.gmail.com>
	<87zj6qs7v8.fsf@x220.int.ebiederm.org>
	<CALCETrVGcCA2SMiDT8JN=AWiSFCXWSaMeKBQmkbKynKfiPJCwA@mail.gmail.com>
	<87oal4odne.fsf@x220.int.ebiederm.org>
	<1432832511.21304.6.camel@redhat.com>
	<87mw0omxp0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mw0omxp0.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2015-05-28 at 12:14 -0500, Eric W. Biederman wrote:
> 
> > Where does the second namespace enter into this? 
> 
> Step a.  Create create a user namespace where uid 0 is mapped to your
> real uid, and set up your sandbox (aka mount /dev/pts and everything
> else).
> 
> Step b.  Create a nested user namespace where your uid is identity
> mapped and run your desktop application.  You can even drop all caps 
> in
> your namespace.

Just tried this. Its not the nicest, and it doubles the number of
namespaces in action for each sandbox, but it does work.
