From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [GIT PATCH] actually check va randomization
Date: Tue, 10 Jun 2008 16:51:59 -0700
Message-ID: <1213141919.7261.21.camel@nimitz>
References: <1209144259.12718.46.camel@nimitz.home.sr71.net>
	<48159D1D.3050302@fr.ibm.com> <481735A6.8070800@bull.net>
	<48173CE1.7050503@fr.ibm.com> <481ECA42.5060603@bull.net>
	<20080609130429.GA16297@us.ibm.com> <484D4612.9000901@bull.net>
	<20080609152336.GA27878@us.ibm.com> <484E1BD3.40401@ozlabs.au.ibm.com>
	<20080610181756.GB13817@us.ibm.com>
	<484F0DC7.5080209@ozlabs.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <484F0DC7.5080209-QcUrd9fbWu1x7SfHBjqd8AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kathys <kathys-QcUrd9fbWu1x7SfHBjqd8AC/G2K4zDHf@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Rather than just documenting this in the readme, actually spit
out a warning on it.

You can pull from: git://git.sr71.net/~dave/cryo-forhallyn.git/

-- Dave
