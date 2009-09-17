From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Thu, 17 Sep 2009 09:53:11 -0700
Message-ID: <20090917165311.GB13855@us.ibm.com>
References: <20090909055636.GA27622@us.ibm.com> <4AA82B7C.8080107@librato.com>
	<20090917013546.GA30161@us.ibm.com> <4AB1A99D.3020307@librato.com>
	<20090917131843.GA29297@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090917131843.GA29297-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > > True. But if originally the application was started as:
| > > 
| > > 	Create container
| > > 	Login to contaienr
| > 
| > Actually, I'm not sure what you mean by "login to container" ?
| 
| I assume he was thinking of a system container created with liblxc
| or libvirt, and literally logging in on its console or over ssh.

Yes, but...
| 
| ...
| 
| > > Yes, that would be really useful I think for things like restoring file
| > > system to its snapshot. Without that there is somewhat of an assymetry
| > > in starting an application in a container and restarting it from a
| > > checkpoint.
| 
| Fine, they are different operations :)

...more than the assymetry, I guess I am not sure what is the "recommended"
way to restart an application, while ensuring filesystem (and network)
are correctly restored by user.

	ns_exec --cpuim -- /usr/bin/restart --wait < checkpoint-image.1

assumes fs/network are setup. Hence the "login" to the container.


| 
| -serge
