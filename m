From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: liblxc and cgroups
Date: Sat, 8 Nov 2008 17:51:08 -0600
Message-ID: <20081108235107.GA15761@us.ibm.com>
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
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Daniel,

I'm playing with liblxc containers and the device whitelist cgroup.
One thing which makes the devices cgroup unique from the others is
that there can be many entries to the devices.allow (and in theory
also to devices.deny) file.  liblxc doesn't support that right now.
This needs to be fixed in two places.

First, lxc_conf.c:write_info needs to write multiple entries
from the .conf file into the cgroups/devices.allow file.  I just
changed the creat(f, 0755) to open(f, O_CREAT|O_WRONLY|O_APPEND, 0755)
which seemed to work for me, but I'm not sure if that might adversely
affect other code which counted on the truncation implicit in creat()?

Secondly, the lxc_cgroup_copy needs to do a loop and write the
entries one by one into the cgroup file.  I'm just doing a dumb
unsafe fgets loop, but I actually don't have that working yet,
(which is why I'm not sending a patch - I figure you can whip
something robust up in 2 seconds)

thanks,
-serge
