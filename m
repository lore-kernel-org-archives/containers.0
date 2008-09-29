From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/10] Enable multiple instances of devpts
Date: Mon, 29 Sep 2008 17:58:14 +0200
Message-ID: <48E0FB16.9050600@fr.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>	<20080912175322.GJ17350@us.ibm.com>	<20080924202616.GB31664@us.ibm.com>	<20080926210347.GB31505@us.ibm.com>	<20080929130131.GA12531@us.ibm.com>	<20080929151828.GA10202@us.ibm.com>
	<20080929152951.GA32518@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080929152951.GA32518-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

>> | > The logic seems simple: With newinstance create a private namespace.
>> | > Without newinstance, bind to initial ns.
>> | 
>> | But if I'm in a container in a new mounts ns and somehow managed 
>> | to umount -l /dev/pts, shouldn't i be able to remount my container's
>> | devpts by just doing 'mount -t devpts devpts /dev/pts'?

yes. That's the track we are following with the mq namespace.

>> Now wouldn't that require us to associate the devpts mount with some
>> notion of a container ? (a namespace object in nsproxy of container-init 
>> like we do with /proc).
> 
> Yes.

and it gets a little bit ugly because you need to maintain an internal
mount associated with the namespace to be able to remount the same
superblock when a :

	$ umount /dev/pts
	$ mount -t devpts devpts /dev/pts'?

is done.

So if you're using the mount option 'newinstance' to unshare the 
namespace, you end up doing the internal mount and the user mount 
under the same call, which is a bit weird, indeed.

C.

>> Yes, after 'umount -l'  we have lost _that_ devpts ns and we may have to
>> 'redo' the relevant container-init parts
> 
> It all just feels fragile.
> 
> I realize this is an attempt to do the 'pure fs approach' you were asked
> to do.  I just don't like the resulting 
