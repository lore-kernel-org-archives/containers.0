From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 10/28] dcache: convert to use new lru list
	infrastructure
Date: Mon, 8 Apr 2013 17:14:44 +0400
Message-ID: <5162C2C4.7010807__40306.9557891742$1365439836$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-11-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090304080507060707090207"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1364548450-28254-11-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

--------------090304080507060707090207
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 03/29/2013 01:13 PM, Glauber Costa wrote:
> +	if (dentry->d_flags & DCACHE_REFERENCED) {
> +		dentry->d_flags &= ~DCACHE_REFERENCED;
> +		spin_unlock(&dentry->d_lock);
> +
> +		/*
> +		 * XXX: this list move should be be done under d_lock. Need to
> +		 * determine if it is safe just to do it under the lru lock.
> +		 */
> +		return 1;
> +	}

I've carefully audited the list manipulations in dcache and determined
this is safe. I've replaced the fixme string for the following text. Let
me know if you believe this is not right.



--------------090304080507060707090207
Content-Type: text/plain; charset="UTF-8"; name="comment"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="comment"

diff --git a/fs/dcache.c b/fs/dcache.c
index a2fc76e..8e166a4 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -855,8 +855,23 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 		spin_unlock(&dentry->d_lock);
 
 		/*
-		 * XXX: this list move should be be done under d_lock. Need to
-		 * determine if it is safe just to do it under the lru lock.
+		 * The list move itself will be made by the common LRU code. At
+		 * this point, we've dropped the dentry->d_lock but keep the
+		 * lru lock. This is safe to do, since every list movement is
+		 * protected by the lru lock even if both locks are held.
+		 *
+		 * This is guaranteed by the fact that all LRU management
+		 * functions are intermediated by the LRU API calls like
+		 * list_lru_add and list_lru_del. List movement in this file
+		 * only ever occur through this functions or through callbacks
+		 * like this one, that are called from the LRU API.
+		 *
+		 * The only exceptions to this are functions like
+		 * shrink_dentry_list, and code that first checks for the
+		 * DCACHE_SHRINK_LIST flag.  Those are guaranteed to be
+		 * operating only with stack provided lists after they are
+		 * properly isolated from the main list.  It is thus, always a
+		 * local access.
 		 */
 		return LRU_ROTATE;
 	}

--------------090304080507060707090207
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------090304080507060707090207--
