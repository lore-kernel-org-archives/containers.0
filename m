From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Wed, 16 Sep 2009 18:35:46 -0700
Message-ID: <20090917013546.GA30161@us.ibm.com>
References: <20090909055636.GA27622@us.ibm.com> <4AA82B7C.8080107@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA82B7C.8080107-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
| 
| 
| Sukadev Bhattiprolu wrote:
| > I have a usage question on the 'restart' (formerly mktree) program.
| > 
| > In the following container c/r case: 
| > 
| > 	- create a container
| > 	- log in to the container,
| > 	- restore filesystem(s) from snapshot
| > 	- restart application from checkpoint
| 
| FWIW, I'd expect that future versions of 'restart' will be capable
| of doing this entire setup, (filesystem(s) included), as it matures.
| 
| Note that this use case that you suggest will only work to restart
| subtrees; it is unsuitable for full containers (with pids) because
| the pid of init (1) will already be in use.

True. But if originally the application was started as:

	Create container
	Login to contaienr
	Set up filesystem
	Start application

The application would not be using the pid 1 right - even if the
application was started from an rc script in the container ?

| 
| Perhaps we should think of some "plugin" architecture for 'restart'
| that will allow the user to ask it to execute some work at between
| creating a new container and actually restarting into it ?

Yes, that would be really useful I think for things like restoring file
system to its snapshot. Without that there is somewhat of an assymetry
in starting an application in a container and restarting it from a
checkpoint.
