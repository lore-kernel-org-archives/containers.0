From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: CLONE_PARENT in a container
Date: Thu, 19 Mar 2009 19:07:49 -0700
Message-ID: <20090320020749.GA31179@us.ibm.com>
References: <49C2C819.4070802@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C2C819.4070802-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cc: Oleg, Eric

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| What happens when a container-init calls clone() with the
| CLONE_PARENT flag set ?
| 
| Since CLONE_PARENT can be used to create a sibling, I'd
| think that this will create a sibling, in particular,  a
| new task in the same container whose parent is the parent
| of the container. From a quick look in the code I can't
| see why this would be impossible.
| 
| Is this so ?  Is this the desired behavior ?

Good question.  CLONE_PARENT was discussed recently on lkml but did
not look obvious to me who uses it or what the semantics are.
Some observations.

	- the "reaper" for this sibling would be the reaper of the
	  parent container, not the init of the new container.

	- if container-init exits, this sibling will also be killed since
	  it has a pid in this container.
	   
Not sure if it needs to be prevented though.  An using CLONE_PARENT
may want to run as a container-init :-) And if CLONE_PARENT is used
with CLONE_THREAD, we don't want to preclude threaded container-inits.

Sukadev
