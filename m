From: Cedric Le Goater <clg@fr.ibm.com>
Subject: debugging threaded apps running under a clone(CLONE_NEWPID)
Date: Fri, 20 Feb 2009 17:56:49 +0100
Message-ID: <499EE0D1.1010001@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757996AbZBTQ5P@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Hello !

to debug threaded apps, gdb uses a special libthread_db which seeks in the
symbols of the exec the list of running threads. This list contains the glibc 
'struct pthread' descriptor with pids and tids which values are relative 
to the namespace in which the threads were created.  

unless you run gdb in the same pid namespace, gdb will not see any thread
in the debugged app. this is frustrating for some scenarios and some 
support from the kernel would be needed to address this issue. Here
are some ideas :

   . enter a pid namespace. hard.  

   . expose the pid numbers of a task in its pid namespaces, through some 
     ways like /proc/self/stat or /proc/self/pids and modify gdb to make 
     the conversion.

How would you do it ? 

Thanks,

C.
