From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: [RFC] Per-user namespace process accounting
Date: Thu, 29 May 2014 09:37:01 +0300
Message-ID: <5386D58D.2080809@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello,

I have the following proposition.

Number of currently running processes is accounted at the root user namespace. The problem I'm facing is that multiple
containers in different user namespaces share the process counters.

So if containerX runs 100 with UID 99, containerY should have NPROC limit of above 100 in order to execute any
processes with ist own UID 99.

I know that some of you will tell me that I should not provision all of my containers with the same UID/GID maps, but
this brings another problem.

We are provisioning the containers from a template. The template has a lot of files 500k and more. And chowning these
causes a lot of I/O and also slows down provisioning considerably.

The other problem is that when we migrate one container from one host machine to another the IDs may be already in use
on the new machine and we need to chown all the files again.

Finally if we use different UID/GID maps we can not do live migration to another node because the UIDs may be already
in use.

So I'm proposing one hack modifying unshare_userns() to allocate new user_struct for the cred that is created for the
first task creating the user_ns and free it in exit_creds().

Can you please comment on that?

Or suggest a better solution?

Best regards,
Marian


- -- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOG1Y0ACgkQ4mt9JeIbjJQREACbBrax+ztBj2Y0P2jY3qYEUY9T
JJ0AnAqLj3pqFFjXCkczEydV1V0LdzQ3
=8M+P
-----END PGP SIGNATURE-----
