From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Thu, 13 Jul 2017 07:11:36 -0500
Message-ID: <87y3rscz9j.fsf__16519.538491457$1499948382$gmane$org@xmission.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com> <20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170713011554.xwmrgkzfwnibvgcu-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org> (Theodore Ts'o's
	message of "Wed, 12 Jul 2017 21:15:54 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> writes:

> I'm really confused what problem that is trying to be solved, here,
> but it **feels** really, really wrong.
>
> Why do we need to store all of this state on a per-file basis, instead
> of some kind of per-file system or per-container data structure?
>
> And how many of these security.foo@uid=bar xattrs do you expect there
> to be?  How many "foo", and how many "bar"?
>
> Maybe I missed the full write up, in which case please send me a link
> to the full writeup --- ideally in the form of a design doc that
> explains the problem statement, gives some examples of how it's going
> to be used, what were the other alternatives that were considered, and
> why they were rejected, etc.

The concise summary:

Today we have the xattr security.capable that holds a set of
capabilities that an application gains when executed.  AKA setuid root exec
without actually being setuid root.

User namespaces have the concept of capabilities that are not global but
are limited to their user namespace.  We do not currently have
filesystem support for this concept.

We currently have two proposals on the table.  One is to bump the
revision number of security.capable and add more information in that xattr.
The other is to use a sligthly different capability name.

We are currently evaluating between the two proposals.

Given that it appears the IMA xattrs will want similar treatment coming
up with a good pattern to follow is part of the analysis here.

Eric
