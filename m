From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 23/85] ocfs2: Convert uid and gids between in core
	and on disk inodes
Date: Thu, 14 Feb 2013 01:10:01 -0800
Message-ID: <877gmbdzx2.fsf__33701.7962513075$1360833038$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-23-git-send-email-ebiederm@xmission.com>
	<20130214083547.GE18408@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130214083547.GE18408@localhost> (Joel Becker's message of
	"Thu, 14 Feb 2013 00:35:48 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org> writes:

> This has the same problem with two machines in different userspace
> namespaces.  Should this be punted to the sysadmin or helped out in the
> filesystem?  Do you define this case as unsupported?

First I define two machines in the same user namespace as two machines
with synchronized password files.

As today connecting two machines without synchronizing the password
entries is a problem, won't work, and is punted to the sysadmin to make
keep from doing something silly.

At the same time I don't want to make it easy to get confused, or cause
breakage.

With these patches ocfs2 only still only works in the initial user
namespace.  I don't set .fs_flags = FS_USERNS_MOUNT in struct
filesystem.  Which means that while users in other user namespaces can
store files on ocfs2, they can't mount ocfs2.

Eric
