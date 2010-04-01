From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Mount remount operations propagating from container to host
	and	other containers.
Date: Thu, 1 Apr 2010 10:00:04 -0500
Message-ID: <20100401150004.GF22648@us.ibm.com>
References: <1270129248.7564.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270129248.7564.43.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael H. Warfield" <mhw-UGBql2FAF+1Wk0Htik3J/w@public.gmane.org>
Cc: containers-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Michael H. Warfield (mhw-UGBql2FAF+1Wk0Htik3J/w@public.gmane.org):
> Running this in one container:
> 
> mount -o remount,rw /srv/readonly
> 
> (I seriously wish this would NOT WORK AT ALL, but it does.  I don't want
> the container to be able to write to that partition at all, like the
> media was RO.  Anybody have any ideas on that one?)

That is what the work to make VFS respect hierarchical user namespaces
is for.  Alas it is a perennial victim of time shortages.  It would
let you mark that fs as being owned by root in the initial user
namespace.  Then root in a child user namespace would only get the
world access rights (like any other stranger user) to the fs and its
files.  If an fs or files should be owned by user 500 in a container,
then inode->i_uid will actually store 500, the fs will store a
user ns id (which only a particular uid in init_user_ns can associate
with a container) in which user 500 is valid, and optionally userids
to use for file access from higher user namespaces.  So the file is
owned by userid 500 in userns 5 which is a child of init_user_ns,
userns 5 is owned by userid 1000 in init_user_ns, so the file is owned
by userid 1000 in init_user_ns.

There are quite a few threads in the containers mailing list archive
between Eric and I about this, if you're interested in the background.

Part of the reason this work seems to refuse to get past 5-patch
prototypes is that only Eric and I seem to be interested.  Maybe now
that there is a serious growing user base around lxc that will change.

-serge
