From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 04/12] userns: Convert cifs to use kuid/kgid where
	appropriate
Date: Tue, 20 Nov 2012 09:22:42 -0800
Message-ID: <87lidwqjdp.fsf__8437.42490183121$1353432202$gmane$org@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-4-git-send-email-ebiederm@xmission.com>
	<CAH2r5mt91Av7w6GQUPNu2A9EGRNbPGGAhMO=EobOMi5Cn8gh5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAH2r5mt91Av7w6GQUPNu2A9EGRNbPGGAhMO=EobOMi5Cn8gh5g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Steve French's message of "Tue, 20 Nov 2012 10:56:40 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Do you have a pointer to the background on kuid/kgid

You might try this lwn article
https://lwn.net/Articles/491310/

In a nutshell each user namespace has it's own view of uid_t and gid_t
values.  Those values are mapped into kernel internal kuid_t and kgid_t
values.  Then user space interfaces convert from kuid_t and kgid_t when
read from userspace.

The initial user namespace as a 1-1 identity mapping between kuid_t and
uid_t values.

kuid_t and kgid_t are not assignment compatible with uid_t and gid_t so
that if the conversions are left out a compile error results.

My strategy is to push kuid_t and kgid_t values as deeply into the
kernel data structures as possible so that there is a high propbability
that when we get it wrong a compile error will happen.

Eric
