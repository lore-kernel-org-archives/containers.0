From: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Detecting the use of a mount in another namespace
Date: Thu, 15 Jan 2015 09:56:05 +0100
Message-ID: <1421312165.8788.7.camel@redhat.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a bit of a weird request, but I'm working on an app sandboxing
system where each container gets /usr read-only bind mounted from a
hardlinked tree. When i update the /usr tree I write the new tree to a
different directory, which avoids affecting any currently running apps
against the old one.

However, after updating I'd like to clean out the old version if it is
not in use. I had a plan for this:
1) Move the old usr to a "has been deleted" location
2) Try to remove a file inside the user (say ".ref") which the app when
running has bind-mounted somewhere
3) if the remove returned EBUSY, then the usr is in use.

However, with the recent changes to the semantics in this area this
doesn't work. The remove always succeeds even if the file is mounted in
some other namespace.

I realize that this is better semantics in general, but that was a quite
useful hack. Is there any other similar way i can detect that something
is in use in "any other namespace".

-- 
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Alexander Larsson                                            Red Hat, Inc 
       alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org            alexander.larsson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org 
He's a benighted drug-addicted werewolf with acid for blood. She's a 
psychotic Bolivian mercenary with an incredible destiny. They fight 
crime! 
