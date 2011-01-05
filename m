From: Mike Hommey <mh-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>
Subject: Containers and /proc/sys/vm/drop_caches
Date: Wed, 5 Jan 2011 10:40:22 +0100
Message-ID: <20110105094022.GA5366@glandium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

[Copy/pasted from a previous message to lkml, where it was suggested to
 try containers@]

Hi,

I noticed that from within a lxc container, writing "3" to
/proc/sys/vm/drop_caches would flush the host page cache. That sounds a
little dangerous for VPS offerings that would be based on lxc, as in one
VPS instance root user could impact the overall performance of the host.
I don't know about other containers but I've been told openvz isn't
subject to this problem.
I only tested the current Debian Squeeze kernel, which is based on
2.6.32.27.

Cheers,

Mike
