From: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>
Subject: Fuse in userns
Date: Wed, 11 Nov 2015 16:49:44 +0200
Message-ID: <CAJFSNy5ur4=PKiQC3_h9eL96vQcmtH3A=3bGujHS5ndnNC+ROQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, SiteGround Operations <operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>, Marian Marinov <mm-108MBtLGafw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Eric,

I'd like to ask you what it would take to have proper support of Fuse
inside usernamespaces. I've looked through the code of fuse and I can
see some things are specifically coded to prevent creating a mount
inside userns. E.g. hard-coded usage of init_user_ns or the check
inside fuse_fill_super to make sure the fd is obtained from the
init_user_ns. I have also read your argument here:
https://lkml.org/lkml/2012/11/12/591

So I'm interested in knowing the following:
 * Are you still actively working on making fuse mountable in non-root
userns, if not is the partial patch available somewhere? I might be
able to do some work on that and hopefully make it upstreamable.

* If the code is not available can you explain what are the main
hurdles in getting this to work? In my experiments I;ve hacked fuse
and I'm able to mount glusterfs inside an LXC container but I suspect
I might have broken some subtle security aspect :)

Regards,
Nikolay
