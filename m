From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Wed, 20 Aug 2008 19:45:31 -0700
Message-ID: <48ACD6CB.5030706@zytor.com>
References: <20080821022126.GA29449@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821022126.GA29449-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> TODO:
> 	- Remove even initial kernel mount of devpts ? (If we do, how
> 	  do we preserve single-mount semantics) ?

Doesn't make sense unless we decide to drop single-mount semantics in 
the (far) future. As long as we have an instance that services 
unconnected ptmx instances, it makes sense to have that instance 
available to the kernel at all times.

I don't like the name "newmnt" for the option; it is not just another 
mount, but a whole new instance of the pty space.

I observe you didn't incorporate my feedback with regards to get_node(). 
   In this scheme, any and all uses of get_node() are bogus; as such, 
you're missing the huge opportunity for cleanup that comes along with 
this whole thing.

This means breaking compatibility in one very minor way, which is if 
people copy device nodes out of /dev/pts, but I am feeling pretty sure 
that that is much better than carrying the ugliness that goes along with 
the current code.  Furthermore, if there are anyone who do something 
that silly, they need to fix it anyway.

The *entire* implementation of devpts_get_tty(), for example, should 
look like:

struct tty_struct *devpts_get_tty(struct inode *inode)
{
	struct super_block *sb = inode->i_sb;
	
	if (sb->s_magic == DEVPTS_SUPER_MAGIC)
		return (struct tty_struct *)inode->i_private;
	else
		return NULL;	/* Higher layer should return -ENXIO */
}

I really appreciate your tackling this implementation.

	-hpa
